# frozen_string_literal: true

module GraphQL
  module PersistedQueries
    module StoreAdapters
      # Memory adapter for storing persisted queries
      class MemoryStoreAdapter < BaseStoreAdapter
        def initialize(**options)
          @storage = {}
          @name = :memory
          @marshal_query = options.fetch(:marshal_query, true)
        end

        def fetch(hash)
          @storage[hash]
        end

        def save(hash, query)
          @storage[hash] = query
        end

        def serialize(query)
          if @marshal_query
            super(query)
          else
            query
          end
        end

        def deserialize(serialized_query)
          if @marshal_query
            super(serialized_query)
          else
            serialized_query
          end
        end
      end
    end
  end
end
