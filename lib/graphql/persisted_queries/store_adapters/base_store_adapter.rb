# frozen_string_literal: true

module GraphQL
  module PersistedQueries
    module StoreAdapters
      # Base class for all store adapters
      class BaseStoreAdapter
        include GraphQL::Tracing::Traceable
        attr_writer :tracers

        def initialize(_options)
          @name = :base
        end

        def fetch_query(hash)
          fetch(hash).tap do |result|
            if result
              trace("fetch_query.cache_hit", adapter: @name)
            else
              trace("fetch_query.cache_miss", adapter: @name)
            end
          end
        end

        def save_query(hash, query)
          trace("save_query", adapter: @name) { save(hash, query) }
        end

        protected

        def fetch(_hash)
          raise NotImplementedError
        end

        def save(_hash, _query)
          raise NotImplementedError
        end

        def trace(key, metadata)
          if @tracers
            key = "persisted_queries.#{key}"
            block_given? ? super : super {}
          elsif block_given?
            yield
          end
        end
      end
    end
  end
end
