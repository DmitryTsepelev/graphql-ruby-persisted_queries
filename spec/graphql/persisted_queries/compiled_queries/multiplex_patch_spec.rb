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

    let(:schema) { build_test_schema(compiled_queries: true) }

    subject do
      schema.multiplex(queries).map(&:to_h)
    end

    context "when cache is partially cold" do
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

    context "when cache is cold" do
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

    context "when cache is warm" do
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
