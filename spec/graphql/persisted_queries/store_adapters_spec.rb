# frozen_string_literal: true

require "spec_helper"

RSpec.describe GraphQL::PersistedQueries::StoreAdapters do
  describe ".build" do
    let(:options) { {} }
    subject { described_class.build(adapter, **options) }

    context "when StoreAdapters::BaseStoreAdapter instance is passed" do
      let(:adapter) do
        GraphQL::PersistedQueries::StoreAdapters::MemoryStoreAdapter.new(**options)
      end

      it { is_expected.to be(adapter) }
    end

    context "when name is passed" do
      let(:adapter) { :memory }

      it { is_expected.to be_a(GraphQL::PersistedQueries::StoreAdapters::MemoryStoreAdapter) }

      context "when adapter is not found" do
        let(:adapter) { :unknown }

        it "raises error" do
          expect { subject }.to raise_error(
            NameError,
            "Persisted query store adapter for :#{adapter} haven't been found"
          )
        end
      end
    end
  end
end
