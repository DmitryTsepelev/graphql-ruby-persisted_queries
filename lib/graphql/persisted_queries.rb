# frozen_string_literal: true

require "graphql/persisted_queries/resolver"
require "graphql/persisted_queries/schema_patch"
require "graphql/persisted_queries/store_adapters"
require "graphql/persisted_queries/version"

module GraphQL
  # Plugin definition
  module PersistedQueries
    def self.use(schema_defn, store: :memory, **options)
      schema_defn.target.singleton_class.prepend(SchemaPatch)
      schema_defn.target.configure_persisted_query_store(store, options)
    end
  end
end
