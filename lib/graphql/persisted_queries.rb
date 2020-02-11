# frozen_string_literal: true

require "graphql/persisted_queries/error_handlers"
require "graphql/persisted_queries/schema_patch"
require "graphql/persisted_queries/store_adapters"
require "graphql/persisted_queries/version"
require "graphql/persisted_queries/builder_helpers"

module GraphQL
  # Plugin definition
  module PersistedQueries
    def self.use(schema_defn, store: :memory, hash_generator: :sha256,
                 error_handler: :default, **options)
      schema = schema_defn.is_a?(Class) ? schema_defn : schema_defn.target

      schema.singleton_class.prepend(SchemaPatch)
      schema.hash_generator = hash_generator
      schema.configure_persisted_query_error_handler(error_handler)
      schema.configure_persisted_query_store(store, options)
    end
  end
end
