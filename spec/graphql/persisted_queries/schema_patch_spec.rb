# frozen_string_literal: true

require "spec_helper"

require "digest"

RSpec.describe GraphQL::PersistedQueries::SchemaPatch do
  QueryType = Class.new(GraphQL::Schema::Object) do
    field :some_data, String, null: false

    def some_data
      "some value"
    end
  end

  TestTracer = Class.new do
    attr_reader :events

    def initialize
      @events = Hash.new { |hash, key| hash[key] = [] }
    end

    def trace(key, value)
      result = yield
      @events[key] << {metadata: value, result: result}
      result
    end
  end

  GraphqlSchema = Class.new(GraphQL::Schema) do
    use GraphQL::PersistedQueries

    query QueryType
  end

  let(:sha256) { Digest::SHA256.hexdigest(query) }

  def perform_request
    GraphqlSchema.execute(query, extensions: { "persistedQuery" => { "sha256Hash" => sha256 } })
  end

  subject(:response) do
    perform_request
  end

  context "when cache is cold" do
    let(:query) { nil }
    let(:sha256) { 1 }

    it "returns error" do
      expect(response[:errors]).to include(message: "PersistedQueryNotFound")
    end
  end

  context "when cache is warm" do
    around do |test|
      original = GraphqlSchema.send(:own_tracers)
      @tracer = TestTracer.new

      GraphqlSchema.tracer(@tracer)
      perform_request
      test.run
      GraphqlSchema.instance_variable_set(:@own_tracers, original)
    end

    let(:query) do
      <<-GQL
        query {
          someData
        }
      GQL
    end

    it "returns data" do
      expect(response["data"]).to eq("someData" => "some value")
    end

    it "emits a tracing event" do
      expect(@tracer.events["persist_query"]).to eq([{metadata: {hash: sha256}, result: query}])
    end
  end
end
