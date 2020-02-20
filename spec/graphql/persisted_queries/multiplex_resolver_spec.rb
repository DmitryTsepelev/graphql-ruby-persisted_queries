# frozen_string_literal: true

require "spec_helper"

require "digest"

RSpec.describe GraphQL::PersistedQueries::MultiplexResolver do
  describe "#resolve" do
    let(:query1) { "query { someData }" }
    let(:query2) { "query { someOtherData }" }

    let(:sha256_1) { Digest::SHA256.hexdigest(query1) }
    let(:sha256_2) { Digest::SHA256.hexdigest(query2) }

    let(:queries) do
      [
        { query: query1, extensions: { "persistedQuery" => { "sha256Hash" => sha256_1 } } },
        { query: query2, extensions: { "persistedQuery" => { "sha256Hash" => sha256_2 } } }
      ]
    end

    let(:schema) { build_test_schema }

    subject do
      described_class.new(schema, queries, {}).resolve
    end

    context "when cache is partially cold" do
      let(:query1) { nil }
      let(:sha256_1) { 1 }

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

      let(:sha256_1) { 1 }
      let(:sha256_2) { 2 }

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
