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
    before { perform_request }

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
  end
end
