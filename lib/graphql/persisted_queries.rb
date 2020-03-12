# frozen_string_literal: true

require "graphql/persisted_queries/error_handlers"
require "graphql/persisted_queries/schema_patch"
require "graphql/persisted_queries/store_adapters"
require "graphql/persisted_queries/version"
require "graphql/persisted_queries/builder_helpers"
require "graphql/persisted_queries/http_method_analyzer"

module GraphQL
  # Plugin definition
  module PersistedQueries
    def self.use(schema_defn, options = {})
      schema = schema_defn.is_a?(Class) ? schema_defn : schema_defn.target
      SchemaPatch.patch(schema)

      schema.hash_generator = options.delete(:hash_generator) || :sha256

      schema.verify_http_method = options.delete(:verify_http_method)

      error_handler = options.delete(:error_handler) || :default
      schema.configure_persisted_query_error_handler(error_handler)

      schema.persisted_queries_tracing_enabled = options.delete(:tracing)

      store = options.delete(:store) || :memory
      schema.configure_persisted_query_store(store, options)
    end
  end
end
