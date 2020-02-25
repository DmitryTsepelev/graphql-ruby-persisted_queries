# frozen_string_literal: true

require "graphql/persisted_queries/hash_generator_builder"
require "graphql/persisted_queries/resolver"
require "graphql/persisted_queries/multiplex_resolver"

module GraphQL
  module PersistedQueries
    # Patches GraphQL::Schema to support persisted queries
    module SchemaPatch
      class << self
        def patch(schema)
          schema.singleton_class.class_eval { alias_method :multiplex_original, :multiplex }
          schema.singleton_class.prepend(SchemaPatch)
        end
      end

      attr_reader :persisted_query_store, :hash_generator_proc, :persisted_query_error_handler
      attr_writer :persisted_queries_tracing_enabled

      def configure_persisted_query_store(store, options)
        @persisted_query_store = StoreAdapters.build(store, options).tap do |adapter|
          adapter.tracers = tracers if persisted_queries_tracing_enabled?
        end
      end

      def configure_persisted_query_error_handler(handler)
        @persisted_query_error_handler = ErrorHandlers.build(handler)
      end

      def hash_generator=(hash_generator)
        @hash_generator_proc = HashGeneratorBuilder.new(hash_generator).build
      end

      def verify_http_method=(verify)
        return unless verify

        analyzer = HttpMethodAnalyzer.new

        if Gem::Dependency.new("graphql", ">= 1.10.0").match?("graphql", GraphQL::VERSION)
          query_analyzer(analyzer)
        else
          query_analyzers << analyzer
        end
      end

      def persisted_queries_tracing_enabled?
        @persisted_queries_tracing_enabled
      end

      def multiplex(queries, **kwargs)
        persisted_query_store.tracers = tracers if persisted_queries_tracing_enabled?
        MultiplexResolver.new(self, queries, kwargs).resolve
      end
    end
  end
end
