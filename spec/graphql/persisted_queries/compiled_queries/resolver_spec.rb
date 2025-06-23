# frozen_string_literal: true

require "spec_helper"

RSpec.describe GraphQL::PersistedQueries::CompiledQueries::Resolver,
               compiled_queries_support: true do
  let(:query) { "query { user }" }
  let(:query_str) { query }
  let(:extensions) { {} }
  let(:parsed_query) { GraphQL.parse(query) }
  let(:compiled_query) { Marshal.dump(parsed_query) }
  let(:store) do
    double("TestStore").tap do |store|
      allow(store).to receive(:save_query)
      allow(store).to receive(:fetch_query).and_return(compiled_query)
    end
  end
  let(:hash_generator_proc) { proc { |value| Digest::SHA256.hexdigest(value) } }
  let(:hash) { hash_generator_proc.call(query) }
  let(:error_handler) { GraphQL::PersistedQueries::ErrorHandlers::DefaultErrorHandler.new }

  let(:schema) do
    double("TestSchema").tap do |schema|
      allow(schema).to receive(:persisted_query_store).and_return(store)
      allow(schema).to receive(:hash_generator_proc).and_return(hash_generator_proc)
      allow(schema).to receive(:persisted_query_error_handler).and_return(error_handler)
    end
  end

  describe "#fetch" do
    subject do
      described_class.new(schema, extensions).fetch
    end

    context "when extensions hash is empty" do
      it { is_expected.to be_nil }
    end

    context "when extensions hash is passed" do
      let(:extensions) do
        { "persistedQuery" => { "sha256Hash" => hash } }
      end

      it { is_expected.to eq(parsed_query) }

      it "fetches query from store" do
        subject
        expect(store).to have_received(:fetch_query).with(hash, compiled_query: true)
      end
    end

    context "when the store fails" do
      let(:extensions) { { "persistedQuery" => { "sha256Hash" => hash } } }

      let(:error_handler) do
        handler = double("TestErrorHandler")
        allow(handler).to receive(:call)
        handler
      end

      let(:error) { StandardError.new }

      let(:store) do
        store = double("TestStore")
        allow(store).to receive(:fetch_query).and_raise(error)
        store
      end

      it "passes the error to the error handler" do
        begin
          subject
        rescue GraphQL::PersistedQueries::Resolver::NotFound
          # Ignore the expected error
        end
        expect(error_handler).to have_received(:call).with(error)
      end
    end
  end

  describe "#persist" do
    subject do
      described_class.new(schema, extensions).persist(query_str, parsed_query)
    end

    context "when extensions hash is empty" do
      it "saves query to store" do
        subject
        expect(store).not_to have_received(:save_query)
      end
    end

    context "when extensions hash is passed" do
      let(:extensions) { { "persistedQuery" => { "sha256Hash" => hash } } }

      it "saves query to store" do
        subject
        expect(store).to have_received(:save_query).with(hash, compiled_query, compiled_query: true)
      end

      context "when hash is incorrect" do
        let(:hash) { "wrong" }

        it "raises exception" do
          expect { subject }.to raise_error(GraphQL::PersistedQueries::WrongHash)
        end
      end
    end

    context "when query_str is not provided" do
      let(:query_str) { nil }

      it "saves query to store" do
        subject
        expect(store).not_to have_received(:save_query)
      end
    end

    context "when the store fails" do
      let(:extensions) { { "persistedQuery" => { "sha256Hash" => hash } } }

      let(:error_handler) do
        handler = double("TestErrorHandler")
        allow(handler).to receive(:call)
        handler
      end
      let(:error) { StandardError.new }

      let(:store) do
        store = double("TestStore")
        allow(store).to receive(:save_query).and_raise(error)
        store
      end

      it "passes the error to the error handler" do
        subject
        expect(error_handler).to have_received(:call).with(error)
      end
    end
  end
end
