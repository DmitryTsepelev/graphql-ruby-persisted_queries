# frozen_string_literal: true

require "spec_helper"

require "redis"
require "connection_pool"

RSpec.describe GraphQL::PersistedQueries::StoreAdapters::BaseStoreAdapter do
  TestableStoreAdapter = Class.new(described_class) do
    def initialize(**options)
      @name = :testable
      @storage = options[:storage]
    end

    def fetch(hash)
      @storage[hash]
    end

    def save(hash, query)
      @storage[hash] = query
    end
  end

  let(:storage) { {} }
  subject { TestableStoreAdapter.new(storage: storage) }

  describe "tracing events" do
    let(:tracer) { TestTracer.new }
    before do
      subject.tracers = [tracer]
    end

    it "emits a cache_miss event", focus: true do
      storage["greenday"] = nil
      subject.fetch_query("greenday")

      expect(tracer.events).to eq(
        "persisted_queries.fetch_query.cache_miss" => [{
          metadata: { adapter: :testable },
          result: nil
        }]
      )
    end

    it "emits a cache_hit event", focus: true do
      storage["greenday"] = "welcome-to-paradise"
      subject.fetch_query("greenday")

      expect(tracer.events).to eq(
        "persisted_queries.fetch_query.cache_hit" => [{
          metadata: { adapter: :testable },
          result: nil
        }]
      )
    end

    it "emits a save_query event", focus: true do
      subject.save_query("greenday", "welcome-to-paradise")

      expect(tracer.events).to eq(
        "persisted_queries.save_query" => [{
          metadata: { adapter: :testable },
          result: "welcome-to-paradise"
        }]
      )
    end
  end
end
