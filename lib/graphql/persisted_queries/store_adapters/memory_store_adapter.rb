# frozen_string_literal: true

module GraphQL
  module PersistedQueries
    module StoreAdapters
      # Memory adapter for storing persisted queries
      class MemoryStoreAdapter < BaseStoreAdapter
        def initialize(**_options)
          @storage = {}
          @name = :memory
        end

        def fetch(hash)
          @storage[hash]
        end

        def save(hash, query)
          @storage[hash] = query
        end
      end
    end
  end
end
