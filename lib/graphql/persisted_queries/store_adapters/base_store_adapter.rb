# frozen_string_literal: true

module GraphQL
  module PersistedQueries
    module StoreAdapters
      # Base class for all store adapters
      class BaseStoreAdapter
        def initialize(_options); end

        def fetch_query(_hash)
          raise NotImplementedError
        end

        def save_query(_hash, _query)
          raise NotImplementedError
        end
      end
    end
  end
end
