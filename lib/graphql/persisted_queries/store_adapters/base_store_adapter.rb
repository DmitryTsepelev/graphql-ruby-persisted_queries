# frozen_string_literal: true

module GraphQL
  module PersistedQueries
    module StoreAdapters
      # Base class for all store adapters
      class BaseStoreAdapter
        include GraphQL::Tracing::Traceable
        attr_writer :tracers

        def initialize(_options); end

        def fetch_query(_hash)
          raise NotImplementedError
        end

        def save_query(_hash, _query)
          raise NotImplementedError
        end

        protected

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
