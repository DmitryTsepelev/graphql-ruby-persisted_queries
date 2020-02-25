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

  Tracer = Class.new do
    attr_reader :events

    def initialize
      clear!
    end

    def trace(key, value)
      result = yield
      @events[key] << { metadata: value, result: result }
      result
    end

    def clear!
      @events = Hash.new { |hash, key| hash[key] = [] }
    end
  end

  let(:query) { "query { someData }" }

  let(:sha256) { Digest::SHA256.hexdigest(query) }

  let(:schema) do
    build_test_schema(error_handler: ErrorHandler.new({}))
  end

  let(:tracer) { Tracer.new }

  let(:schema_with_tracer) do
    build_test_schema(error_handler: ErrorHandler.new({}), tracing: true, tracer: tracer)
  end

  describe "#execute" do
    def perform_request(with_tracer: false, with_query: true)
      current_schema = with_tracer ? schema_with_tracer : schema
      selected_query = with_query ? query : nil
      tracer.clear! if with_tracer

      current_schema.execute(selected_query,
                             extensions: { "persistedQuery" => { "sha256Hash" => sha256 } })
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
        expect(events).to eq([{ metadata: { adapter: :memory }, result: nil }])
      end
    end

    context "when cache is unavailable" do
      let(:query) { nil }
      let(:sha256) { 1 }

      UnavailableStore = Class.new(GraphQL::PersistedQueries::StoreAdapters::BaseStoreAdapter) do
        def fetch_query(_)
          raise "Store unavailable"
        end

        def save_query(_, _)
          raise "Store unavailable"
        end
      end

      around do |test|
        original_store = schema.persisted_query_store
        schema.configure_persisted_query_store(UnavailableStore.new({}), {})
        begin
          test.run
        ensure
          schema.configure_persisted_query_store(original_store, {})
        end
      end

      it "calls the error handler" do
        # rubocop: disable Lint/HandleExceptions
        begin
          schema.execute(
            query, extensions: { "persistedQuery" => { "sha256Hash" => sha256 } }
          )
        rescue RuntimeError
          # Ignore the expected error
        end
        # rubocop: enable Lint/HandleExceptions

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
          extensions: { "persistedQuery" => { "sha256Hash" => Digest::SHA256.hexdigest(query) } }
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
end
