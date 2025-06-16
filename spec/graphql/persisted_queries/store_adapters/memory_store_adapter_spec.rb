# frozen_string_literal: true

require "spec_helper"

RSpec.describe GraphQL::PersistedQueries::StoreAdapters::MemoryStoreAdapter do
  subject { described_class.new(**options) }

  let(:storage) { subject.instance_variable_get(:@storage) }

  let(:key) { "key" }
  let(:value) { "value" }

  before { subject.save(key, value) }

  context "when `marshal_inmemory_queries` is to to a truthy value" do
    let(:options) { { marshal_inmemory_queries: true } }

    it "loads serialized value by provided key" do
      expect(storage.fetch(key)).to eq(Marshal.dump(value))
      expect(subject.fetch(key)).to eq(value)
    end
  end

  context "when `marshal_inmemory_queries` is to to a falsey value" do
    let(:options) { { marshal_inmemory_queries: false } }

    it "loads serialized value by provided key" do
      expect(storage.fetch(key)).to eq(value)
      expect(subject.fetch(key)).to eq(value)
    end
  end
end
