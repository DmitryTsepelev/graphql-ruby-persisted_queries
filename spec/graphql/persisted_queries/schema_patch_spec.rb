# frozen_string_literal: true

require "spec_helper"

require "digest"

RSpec.describe GraphQL::PersistedQueries::SchemaPatch do
  ErrorHandler = Class.new(GraphQL::PersistedQueries::ErrorHandlers::BaseErrorHandler) do
    attr_accessor :last_handled_error

    def call(error)
      self.last_handled_error = error
      raise error
    end
  end

  let(:query) { "query { someData }" }

  let(:sha256) { Digest::SHA256.hexdigest(query) }

  let(:schema) do
    build_test_schema(error_handler: ErrorHandler.new)
  end

  let(:tracer) { TestTracer.new }

  describe "#execute" do
    let(:schema_with_tracer) do
      build_test_schema(error_handler: ErrorHandler.new, tracing: true, tracer: tracer)
    end

    def perform_request(with_tracer: false, with_query: true)
      current_schema = with_tracer ? schema_with_tracer : schema
      selected_query = with_query ? query : nil
      tracer.clear! if with_tracer

      current_schema.execute(
        selected_query,
        context: {
          extensions: { "persistedQuery" => { "sha256Hash" => sha256 } }
        }
      )
    end

    subject(:response) { perform_request }

    context "when cache is cold" do
      let(:query) { nil }
      let(:sha256) { 1 }

      it "returns error" do
        expect(response["errors"]).to eq([{ "message" => "PersistedQueryNotFound" }])
      end

      it "emits a cache miss" do
        perform_request(with_tracer: true)
        events = tracer.events["persisted_queries.fetch_query.cache_miss"]
        expect(events).to eq([{ metadata: { adapter: :memory }, result: nil }])
      end
    end

    context "when cache is populated" do
      it "emits a query save event" do
        perform_request(with_tracer: true, with_query: true)
        events = tracer.events["persisted_queries.save_query"]
        expect(events).to eq([{ metadata: { adapter: :memory }, result: query }])
      end
    end

    context "when cache is warm" do
      subject(:response) { perform_request(with_query: false) }

      it "returns data" do
        perform_request
        expect(response["data"]).to eq("someData" => "some value")
      end

      it "emits a cache hit" do
        perform_request(with_tracer: true)
        perform_request(with_tracer: true, with_query: false)
        events = tracer.events["persisted_queries.fetch_query.cache_hit"]
        expect(events).to eq([{ metadata: { adapter: :memory }, result: query }])
      end
    end

    context "when cache is unavailable" do
      let(:query) { nil }
      let(:sha256) { 1 }

      UnavailableStore = Class.new(GraphQL::PersistedQueries::StoreAdapters::BaseStoreAdapter) do
        def fetch_query(_, **_)
          raise "Store unavailable"
        end

        def save_query(_, _, **_)
          raise "Store unavailable"
        end
      end

      around do |test|
        original_store = schema.persisted_query_store
        schema.configure_persisted_query_store(UnavailableStore.new)
        begin
          test.run
        ensure
          schema.configure_persisted_query_store(original_store)
        end
      end

      it "calls the error handler" do
        begin
          schema.execute(
            query,
            context: { extensions: { "persistedQuery" => { "sha256Hash" => sha256 } } }
          )
        rescue RuntimeError
          # Ignore the expected error
        end
        expect(
          schema.persisted_query_error_handler.last_handled_error
        ).to be_a(RuntimeError)
      end
    end
  end

  describe "#multiplex" do
    let(:queries) do
      [
        {
          query: query,
          context: {
            extensions: {
              "persistedQuery" => { "sha256Hash" => Digest::SHA256.hexdigest(query) }
            }
          }
        }
      ]
    end

    def perform_request
      schema.multiplex(queries)
    end

    subject(:response) { perform_request }

    it "returns data" do
      expect(subject).to eq([{ "data" => { "someData" => "some value" } }])
    end
  end

  describe "inheritance" do
    let(:schema) { build_test_schema }

    let(:inherited_schema) { Class.new(schema) }

    describe "persisted_query_error_handler" do
      it "inherits error handler" do
        expect(schema.persisted_query_error_handler).to \
          eq(inherited_schema.persisted_query_error_handler)
      end

      context "when error handler is custom" do
        let(:schema) do
          build_test_schema(error_handler: ErrorHandler.new)
        end

        it "inherits error handler" do
          expect(schema.persisted_query_error_handler).to \
            eq(inherited_schema.persisted_query_error_handler)
        end
      end
    end

    describe "persisted_query_store" do
      it "inherits persisted_query_store handler" do
        expect(schema.persisted_query_store).to \
          eq(inherited_schema.persisted_query_store)
      end

      context "when store is custom" do
        # rubocop:disable Layout/LineLength
        class CustomMemoryStoreAdapter < GraphQL::PersistedQueries::StoreAdapters::MemoryStoreAdapter; end
        # rubocop:enable Layout/LineLength

        let(:schema) do
          build_test_schema(store: CustomMemoryStoreAdapter.new)
        end

        it "inherits persisted_query_store" do
          expect(schema.persisted_query_store).to \
            eq(inherited_schema.persisted_query_store)

          expect(inherited_schema.persisted_query_store).to be_a(CustomMemoryStoreAdapter)
        end
      end
    end

    describe "hash_generator" do
      it "inherits hash_generator_proc handler" do
        expect(schema.hash_generator_proc).to \
          eq(inherited_schema.hash_generator_proc)
      end

      context "when hash_generator is custom" do
        let(:custom_hash_generator) { proc { |_| "42" } }

        let(:schema) do
          build_test_schema(hash_generator: custom_hash_generator)
        end

        it "inherits hash_generator_proc handler" do
          expect(schema.hash_generator_proc).to \
            eq(inherited_schema.hash_generator_proc)
        end
      end
    end

    describe "verify_http_method" do
      it "not sets up analyzer" do
        expect(inherited_schema.query_analyzers).to be_empty
      end

      context "when verify_http_method is set to true in parent schema" do
        let(:schema) do
          build_test_schema(verify_http_method: true)
        end

        it "sets up analyzer" do
          expect(inherited_schema.query_analyzers).not_to be_empty
        end
      end
    end

    describe "persisted_queries_tracing_enabled" do
      it "sets persisted_queries_tracing_enabled to false" do
        expect(inherited_schema.persisted_queries_tracing_enabled?).to be_falsey
      end

      context "when persisted_queries_tracing_enabled is set to true in parent schema" do
        let(:schema) do
          build_test_schema(tracing: true)
        end

        it "sets persisted_queries_tracing_enabled to true" do
          expect(inherited_schema.persisted_queries_tracing_enabled?).to eq(true)
        end
      end
    end
  end
end
