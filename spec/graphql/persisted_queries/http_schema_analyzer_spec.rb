# frozen_string_literal: true

require "spec_helper"

require "digest"
require "ostruct"

RSpec.describe GraphQL::PersistedQueries::SchemaPatch do
  let(:schema) do
    Class.new(GraphQL::Schema) do
      use GraphQL::PersistedQueries, verify_http_method: true

      query(
        Class.new(GraphQL::Schema::Object) do
          graphql_name "Query"

          field :some_data, String, null: false

          def some_data
            "some value"
          end
        end
      )

      mutation(
        Class.new(GraphQL::Schema::Object) do
          graphql_name "Mutation"

          field :change_data, String, null: false

          def change_data
            "data changed"
          end
        end
      )
    end
  end

  let(:request) { nil }

  def perform_request
    schema.execute(query, context: { request: request })
  end

  subject(:response) do
    perform_request
  end

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
    expect(response["errors"]).to be_nil
  end

  context "when request is GET" do
    let(:request) { OpenStruct.new(get?: true) }

    it "returns data" do
      expect(response["data"]).to eq("someData" => "some value")
      expect(response["errors"]).to be_nil
    end

    context "when mutation is performed" do
      let(:query) do
        <<-GQL
          mutation {
            changeData
          }
        GQL
      end

      it "returns error" do
        expect(response["data"]).to be_nil
        expect(response["errors"]).to eq(
          ["message" => "Mutations cannot be performed via HTTP GET"]
        )
      end
    end
  end

  context "when request is not GET" do
    let(:request) { OpenStruct.new(get?: false) }

    it "returns data" do
      expect(response["data"]).to eq("someData" => "some value")
      expect(response["errors"]).to be_nil
    end

    context "when mutation is performed" do
      let(:query) do
        <<-GQL
          mutation {
            changeData
          }
        GQL
      end

      it "returns data" do
        expect(response["data"]).to eq("changeData" => "data changed")
        expect(response["errors"]).to be_nil
      end
    end
  end
end
