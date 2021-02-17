# frozen_string_literal: true

require "spec_helper"

require "digest"

RSpec.describe GraphQL::PersistedQueries::CompiledQueries::MultiplexPatch do
  if Gem::Dependency.new("graphql", "< 1.12.0").match?("graphql", GraphQL::VERSION)
    it "raises error" do
      expect { build_test_schema(compiled_queries: true) }.to raise_error(
        ArgumentError, "compiled_queries are not supported for graphql-ruby < 1.12.0"
      )
    end
  else
    let(:schema) { build_test_schema(compiled_queries: true) }

    describe "#execute" do
      let(:query_string) { "query { someData }" }
      let(:query) { query_string }
      let(:sha256) { Digest::SHA256.hexdigest(query_string) }
      let(:context) { { extensions: { "persistedQuery" => { "sha256Hash" => sha256 } } } }

      subject do
        schema.execute(query, context: context).to_h
      end

      before do
        allow(GraphQL).to receive(:parse).and_call_original
        allow(schema.persisted_query_store).to receive(:save_query).and_call_original
      end

      context "when query is not passed" do
        let(:query) { nil }

        it "returns error" do
          expect(subject).to eq("errors" => [{ "message" => "PersistedQueryNotFound" }])
        end

        it "not calls GraphQL.parse" do
          subject
          expect(GraphQL).not_to have_received(:parse)
        end

        it "not persists query" do
          subject
          expect(schema.persisted_query_store).not_to have_received(:save_query)
        end

        context "when cache is warm" do
          before do
            schema.execute(query_string, context: context)
          end

          it "returns data" do
            expect(subject).to eq("data" => { "someData" => "some value" })
          end

          it "not calls GraphQL.parse" do
            expect(GraphQL).to have_received(:parse).once
            subject
            expect(GraphQL).to have_received(:parse).once
          end
        end
      end

      context "when query is passed" do
        it "returns data" do
          expect(subject).to eq("data" => { "someData" => "some value" })
        end

        it "calls GraphQL.parse" do
          subject
          expect(GraphQL).to have_received(:parse)
        end

        it "persists query" do
          subject
          expect(schema.persisted_query_store).to have_received(:save_query)
        end

        context "when cache is warm" do
          before do
            schema.execute(query_string, context: context)
          end

          it "returns data" do
            expect(subject).to eq("data" => { "someData" => "some value" })
          end

          it "not persists query" do
            expect(schema.persisted_query_store).to have_received(:save_query).once
            subject
            expect(schema.persisted_query_store).to have_received(:save_query).once
          end

          it "not calls GraphQL.parse" do
            expect(GraphQL).to have_received(:parse).once
            subject
            expect(GraphQL).to have_received(:parse).once
          end

          it "not persists query" do
            expect(schema.persisted_query_store).to have_received(:save_query).once
            subject
            expect(schema.persisted_query_store).to have_received(:save_query).once
          end
        end
      end
    end

    describe "#multiplex" do
      let(:query_string_1) { "query { someData }" }
      let(:query_string_2) { "query { someOtherData }" }

      let(:query1) { query_string_1 }
      let(:query2) { query_string_2 }

      let(:sha256_1) { Digest::SHA256.hexdigest(query_string_1) }
      let(:sha256_2) { Digest::SHA256.hexdigest(query_string_2) }

      let(:queries) do
        [
          {
            query: query1,
            context: { extensions: { "persistedQuery" => { "sha256Hash" => sha256_1 } } }
          },
          {
            query: query2,
            context: { extensions: { "persistedQuery" => { "sha256Hash" => sha256_2 } } }
          }
        ]
      end

      subject do
        schema.multiplex(queries).map(&:to_h)
      end

      context "when all queries are not passed" do
        let(:query1) { nil }
        let(:query2) { nil }

        it "returns errors" do
          expect(subject).to eq(
            [
              { "errors" => [{ "message" => "PersistedQueryNotFound" }] },
              { "errors" => [{ "message" => "PersistedQueryNotFound" }] }
            ]
          )
        end
      end

      context "when one query is not passed" do
        let(:query1) { nil }

        it "returns error and data" do
          expect(subject).to eq(
            [
              { "errors" => [{ "message" => "PersistedQueryNotFound" }] },
              { "data" => { "someOtherData" => "some other value" } }
            ]
          )
        end
      end

      context "when all queries are passed" do
        it "returns data" do
          expect(subject).to eq(
            [
              { "data" => { "someData" => "some value" } },
              { "data" => { "someOtherData" => "some other value" } }
            ]
          )
        end
      end
    end
  end
end
