# frozen_string_literal: true

module GraphQL
  module PersistedQueries
    module StoreAdapters
      # Memory adapter for storing persisted queries
      class RedisWithLocalCacheStoreAdapter < BaseStoreAdapter
        DEFAULT_REDIS_ADAPTER_CLASS = RedisStoreAdapter
        DEFAULT_MEMORY_ADAPTER_CLASS = MemoryStoreAdapter

        def initialize(redis_client: {}, expiration: nil, namespace: nil, redis_adapter_class: nil,
                       memory_adapter_class: nil)
          redis_adapter_class ||= DEFAULT_REDIS_ADAPTER_CLASS
          memory_adapter_class ||= DEFAULT_MEMORY_ADAPTER_CLASS

          @redis_adapter = redis_adapter_class.new(
            redis_client: redis_client,
            expiration: expiration,
            namespace: namespace
          )
          @memory_adapter = memory_adapter_class.new
          @name = :redis_with_local_cache
        end

        # We don't need to implement our own traces for this adapter since the
        # underlying adapters will emit the proper events for us.  However,
        # since tracers can be defined at any time, we need to pass them through.
        def tracers=(tracers)
          @memory_adapter.tracers = tracers
          @redis_adapter.tracers = tracers
        end

        def fetch(hash)
          result = @memory_adapter.fetch(hash)
          result ||= begin
            inner_result = @redis_adapter.fetch(hash)
            @memory_adapter.save(hash, inner_result) if inner_result
            inner_result
          end
          result
        end

        def save(hash, query)
          @redis_adapter.save(hash, query)
          @memory_adapter.save(hash, query)
        end

        private

        attr_reader :redis_adapter, :memory_adapter
      end
    end
  end
end
