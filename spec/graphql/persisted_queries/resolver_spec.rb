# frozen_string_literal: true

require "spec_helper"

require "digest"

RSpec.describe GraphQL::PersistedQueries::Resolver do
  describe "#resolve" do
    let(:extensions) { {} }
    let(:store) do
      store = double("TestStore")
      allow(store).to receive(:save_query)
      allow(store).to receive(:fetch_query).and_return(query)
      store
    end
    let(:query) { "query { user }" }
    let(:query_str) { query }
    let(:hash) { Digest::SHA256.hexdigest(query_str) }

    subject { described_class.new(extensions, store).resolve(query_str) }

    context "when hash is nil" do
      it { is_expected.to eq(query) }
    end

    context "when hash is passed" do
      let(:extensions) do
        { "persistedQuery" => { "sha256Hash" => hash } }
      end

      context "when query_str is provided" do
        it { is_expected.to eq(query) }

        it "saves query to store" do
          subject
          expect(store).to have_received(:save_query).with(hash, query_str)
        end

        context "when hash is incorrect" do
          let(:hash) { "wrong" }

          it "raises exception" do
            expect { subject }.to raise_error(
              GraphQL::PersistedQueries::Resolver::WrongHash
            )
          end
        end
      end

      context "when query_str is not provided" do
        let(:query_str) { nil }
        let(:hash) { Digest::SHA256.hexdigest(query) }

        it { is_expected.to eq(query) }

        it "fetches query from store" do
          subject
          expect(store).to have_received(:fetch_query).with(hash)
        end
      end
    end
  end
end
