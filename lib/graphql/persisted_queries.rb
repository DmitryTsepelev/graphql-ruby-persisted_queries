# frozen_string_literal: true

require "graphql/persisted_queries/resolver_helpers"
require "graphql/persisted_queries/errors"
require "graphql/persisted_queries/error_handlers"
require "graphql/persisted_queries/schema_patch"
require "graphql/persisted_queries/store_adapters"
require "graphql/persisted_queries/version"
require "graphql/persisted_queries/builder_helpers"

require "graphql/persisted_queries/compiled_queries/resolver"
require "graphql/persisted_queries/compiled_queries/multiplex_patch"
require "graphql/persisted_queries/compiled_queries/interpreter_patch"
require "graphql/persisted_queries/compiled_queries/query_patch"

module GraphQL
  # Plugin definition
  module PersistedQueries
    # rubocop:disable Metrics/MethodLength
    def self.use(schema_defn, **options)
      schema = schema_defn.is_a?(Class) ? schema_defn : schema_defn.target

      compiled_queries = options.delete(:compiled_queries)
      SchemaPatch.patch(schema, compiled_queries)
      configure_compiled_queries if compiled_queries

      schema.hash_generator = options.delete(:hash_generator) || :sha256

      schema.verify_http_method = options.delete(:verify_http_method)

      error_handler = options.delete(:error_handler) || :default
      schema.configure_persisted_query_error_handler(error_handler)

      schema.persisted_queries_tracing_enabled = options.delete(:tracing)

      store = options.delete(:store) || :memory
      schema.configure_persisted_query_store(store, **options)
    end
    # rubocop:enable Metrics/MethodLength

    def self.configure_compiled_queries # rubocop:disable Metrics/MethodLength
      if Gem::Dependency.new("graphql", "< 1.12.0").match?("graphql", GraphQL::VERSION)
        raise ArgumentError, "compiled_queries are not supported for graphql-ruby < 1.12.0"
      end

      if Gem::Dependency.new("graphql", ">= 2.0.14").match?("graphql", GraphQL::VERSION)
        GraphQL::Execution::Interpreter.singleton_class.prepend(
          GraphQL::PersistedQueries::CompiledQueries::InterpreterPatch
        )
      else
        GraphQL::Execution::Multiplex.singleton_class.prepend(
          GraphQL::PersistedQueries::CompiledQueries::MultiplexPatch
        )
      end

      GraphQL::Query.prepend(GraphQL::PersistedQueries::CompiledQueries::QueryPatch)
    end
  end
end
