# frozen_string_literal: true

require "spec_helper"

require "redis"
require "connection_pool"

RSpec.describe GraphQL::PersistedQueries::StoreAdapters::RedisWithLocalCacheStoreAdapter do
  subject { described_class.new(**options) }

  let(:redis_client) { { redis_url: "redis://127.0.0.3:8791/3" } }
  let(:mock_redis_adapter) { double("RedisStoreAdapterDouble") }
  let(:redis_adapter_class) do
    klass = double("RedisStoreAdapterClassDouble")
    allow(klass).to receive(:new).and_return(mock_redis_adapter)
    klass
  end
  let(:mock_memory_adapter) { double("MemoryStoreAdapterDouble") }
  let(:memory_adapter_class) do
    klass = double("MemoryStoreAdapterClassDouble")
    allow(klass).to receive(:new).and_return(mock_memory_adapter)
    klass
  end
  let(:options) do
    {
      redis_client: redis_client,
      expiration: nil,
      namespace: nil,
      redis_adapter_class: redis_adapter_class,
      memory_adapter_class: memory_adapter_class
    }
  end

  let(:versioned_key_prefix) { "#{RUBY_ENGINE}-#{RUBY_VERSION}:#{GraphQL::VERSION}" }

  context "when configuring the redis adapter" do
    it "passes config options to adapter" do
      subject
      expect(redis_adapter_class).to have_received(:new).with(redis_client: options[:redis_client],
                                                              expiration: options[:expiration],
                                                              namespace: options[:namespace])
    end
  end

  context "when fetching queries" do
    it "delegates to the memory adapter" do
      expect(mock_memory_adapter).to \
        receive(:fetch).with("#{versioned_key_prefix}:abc123").and_return("result!")

      subject.fetch_query("abc123")
    end

    context "with memory adapter cache miss and compiled_query false" do
      before do
        allow(mock_memory_adapter).to \
          receive(:fetch).with("#{versioned_key_prefix}:abc123").and_return(nil)

        allow(mock_memory_adapter).to receive(:save)
      end

      it "delegates to the redis adapter" do
        expect(mock_redis_adapter).to \
          receive(:fetch).with("#{versioned_key_prefix}:abc123").and_return("result!")
        subject.fetch_query("abc123")
      end

      context "with redis adapter cache miss" do
        before do
          allow(mock_redis_adapter).to \
            receive(:fetch).with("#{versioned_key_prefix}:abc123").and_return(nil)
        end

        it "doesn't persist the result to the memory adapter" do
          expect(mock_memory_adapter).not_to receive(:save)
          subject.fetch_query("abc123")
        end
      end

      context "with redis adapter cache hit" do
        before do
          allow(mock_redis_adapter).to \
            receive(:fetch).with("#{versioned_key_prefix}:abc123").and_return("result!")
        end

        it "persists the result to the memory adapter" do
          expect(mock_memory_adapter).to \
            receive(:save).with("#{versioned_key_prefix}:abc123", "result!")

          subject.fetch_query("abc123")
        end
      end
    end

    context "with memory adapter cache miss and compiled_query true" do
      before do
        allow(mock_memory_adapter).to \
          receive(:fetch).with("compiled:#{versioned_key_prefix}:abc123").and_return(nil)

        allow(mock_memory_adapter).to receive(:save)
      end

      it "delegates to the redis adapter" do
        expect(mock_redis_adapter).to \
          receive(:fetch).with("compiled:#{versioned_key_prefix}:abc123").and_return("result!")
        subject.fetch_query("abc123", compiled_query: true)
      end

      context "with redis adapter cache miss" do
        before do
          allow(mock_redis_adapter).to \
            receive(:fetch).with("compiled:#{versioned_key_prefix}:abc123").and_return(nil)
        end

        it "doesn't persist the result to the memory adapter" do
          expect(mock_memory_adapter).not_to receive(:save)
          subject.fetch_query("abc123", compiled_query: true)
        end
      end

      context "with redis adapter cache hit" do
        before do
          allow(mock_redis_adapter).to \
            receive(:fetch).with("compiled:#{versioned_key_prefix}:abc123").and_return("result!")
        end

        it "persists the result to the memory adapter" do
          expect(mock_memory_adapter).to \
            receive(:save).with("compiled:#{versioned_key_prefix}:abc123", "result!")

          subject.fetch_query("abc123", compiled_query: true)
        end
      end
    end
  end

  context "when saving queries" do
    it "dispatches to both adapters" do
      expect(mock_memory_adapter).to \
        receive(:save).with("#{versioned_key_prefix}:abc123", "result!")

      expect(mock_redis_adapter).to \
        receive(:save).with("#{versioned_key_prefix}:abc123", "result!")

      subject.save_query("abc123", "result!")
    end
  end
end
