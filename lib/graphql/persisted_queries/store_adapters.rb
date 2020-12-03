# frozen_string_literal: true

require "graphql/persisted_queries/store_adapters/base_store_adapter"
require "graphql/persisted_queries/store_adapters/memory_store_adapter"
require "graphql/persisted_queries/store_adapters/redis_store_adapter"
require "graphql/persisted_queries/store_adapters/redis_with_local_cache_store_adapter"
require "graphql/persisted_queries/store_adapters/memcached_store_adapter"

module GraphQL
  module PersistedQueries
    # Contains factory methods for store adapters
    module StoreAdapters
      def self.build(adapter, **options)
        if adapter.is_a?(StoreAdapters::BaseStoreAdapter)
          adapter
        else
          build_by_name(adapter, **options)
        end
      end

      def self.build_by_name(name, **options)
        const_get("#{BuilderHelpers.camelize(name)}StoreAdapter").new(**options)
      rescue NameError => e
        raise e.class, "Persisted query store adapter for :#{name} haven't been found", e.backtrace
      end
    end
  end
end
