# frozen_string_literal: true

module GraphQL
  module PersistedQueries
    module StoreAdapters
      # Memory adapter for storing persisted queries
      class MemoryStoreAdapter < BaseStoreAdapter
        def initialize(_options)
          @storage = {}
        end

        def fetch_query(hash)
          @storage[hash].tap do |result|
            if result
              trace("fetch_query.cache_hit", adapter: :memory)
            else
              trace("fetch_query.cache_miss", adapter: :memory)
            end
          end
        end

        def save_query(hash, query)
          trace("save_query", adapter: :memory) do
            @storage[hash] = query
          end
        end
      end
    end
  end
end
