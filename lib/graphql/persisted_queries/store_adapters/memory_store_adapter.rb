# frozen_string_literal: true

module GraphQL
  module PersistedQueries
    module StoreAdapters
      # Memory adapter for storing persisted queries
      class MemoryStoreAdapter < BaseStoreAdapter
        def initialize(**options)
          @storage = {}
          @name = :memory
          @marshal_inmemory_queries = options.fetch(:marshal_inmemory_queries, true)
        end

        def fetch(hash)
          deserialize(@storage[hash])
        end

        def save(hash, query)
          @storage[hash] = serialize(query)
        end

        def serialize(query)
          if @marshal_inmemory_queries
            super(query)
          else
            query
          end
        end

        def deserialize(serialized_query)
          return unless serialized_query

          if @marshal_inmemory_queries
            super(serialized_query)
          else
            serialized_query
          end
        end
      end
    end
  end
end
