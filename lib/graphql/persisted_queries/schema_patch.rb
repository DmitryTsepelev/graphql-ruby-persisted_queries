# frozen_string_literal: true

require "graphql/persisted_queries/hash_generator_builder"
require "graphql/persisted_queries/resolver"
require "graphql/persisted_queries/multiplex_resolver"
require "graphql/persisted_queries/analyzers/http_method_validator"

module GraphQL
  module PersistedQueries
    # Patches GraphQL::Schema to support persisted queries
    module SchemaPatch
      class << self
        def patch(schema, compiled_queries)
          schema.singleton_class.prepend(SchemaPatch)

          return if compiled_queries

          schema.singleton_class.class_eval { alias_method :multiplex_original, :multiplex }
          schema.singleton_class.prepend(MultiplexPatch)
        end
      end

      # Patches GraphQL::Schema to override multiplex (not needed for compiled queries)
      module MultiplexPatch
        def multiplex(queries, **kwargs)
          MultiplexResolver.new(self, queries, **kwargs).resolve
        end
      end

      attr_reader :persisted_query_store, :hash_generator_proc, :persisted_query_error_handler
      attr_writer :persisted_queries_tracing_enabled

      def configure_persisted_query_store(store, **options)
        @persisted_query_store = StoreAdapters.build(store, **options).tap do |adapter|
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

        if graphql10?
          query_analyzer(prepare_analyzer)
        else
          query_analyzers << prepare_analyzer
        end
      end

      def persisted_queries_tracing_enabled?
        @persisted_queries_tracing_enabled
      end

      def tracer(name)
        super.tap do
          # Since tracers can be set before *and* after our plugin hooks in,
          # we need to set tracers both when this plugin gets initialized
          # and any time a tracer is added after initialization
          persisted_query_store.tracers = tracers if persisted_queries_tracing_enabled?
        end
      end

      private

      def graphql10?
        Gem::Dependency.new("graphql", ">= 1.10.0").match?("graphql", GraphQL::VERSION)
      end

      def prepare_analyzer
        if graphql10? && using_ast_analysis?
          require "graphql/persisted_queries/analyzers/http_method_ast_analyzer"
          Analyzers::HttpMethodAstAnalyzer
        else
          require "graphql/persisted_queries/analyzers/http_method_analyzer"
          Analyzers::HttpMethodAnalyzer.new
        end
      end
    end
  end
end
