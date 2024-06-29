# frozen_string_literal: true

require "graphql/persisted_queries/hash_generator_builder"
require "graphql/persisted_queries/resolver"
require "graphql/persisted_queries/multiplex_resolver"
require "graphql/persisted_queries/compiled_queries/instrumentation"
require "graphql/persisted_queries/analyzers/http_method_validator"

module GraphQL
  module PersistedQueries
    # Patches GraphQL::Schema to support persisted queries
    module SchemaPatch
      class << self
        def patch(schema, compiled_queries)
          schema.singleton_class.prepend(SchemaPatch)

          if compiled_queries
            configure_compiled_queries(schema)
          else
            schema.singleton_class.class_eval { alias_method :multiplex_original, :multiplex }
            schema.singleton_class.prepend(MultiplexPatch)
          end
        end

        private

        def configure_compiled_queries(schema)
          if graphql_ruby_after_2_2_5?
            schema.trace_with(GraphQL::PersistedQueries::CompiledQueries::Instrumentation::Tracer)
          else
            schema.instrument :query, CompiledQueries::Instrumentation
          end
        end

        def graphql_ruby_after_2_2_5?
          check_graphql_version "> 2.2.5"
        end

        def check_graphql_version(predicate)
          Gem::Dependency.new("graphql", predicate).match?("graphql", GraphQL::VERSION)
        end
      end

      # Patches GraphQL::Schema to override multiplex (not needed for compiled queries)
      module MultiplexPatch
        def multiplex(queries, **kwargs)
          MultiplexResolver.new(self, queries, **kwargs).resolve
        end
      end

      attr_writer :persisted_queries_tracing_enabled

      def configure_persisted_query_store(store, **options)
        @persisted_query_store = StoreAdapters.build(store, **options).tap do |adapter|
          adapter.tracers = tracers if persisted_queries_tracing_enabled?
        end
      end

      def persisted_query_store
        @persisted_query_store ||= find_inherited_value(:persisted_query_store)
      end

      def persisted_query_error_handler
        @persisted_query_error_handler ||= find_inherited_value(:persisted_query_error_handler)
      end

      def configure_persisted_query_error_handler(handler)
        @persisted_query_error_handler = ErrorHandlers.build(handler)
      end

      def hash_generator=(hash_generator)
        @hash_generator_proc = HashGeneratorBuilder.new(hash_generator).build
      end

      def hash_generator_proc
        @hash_generator_proc ||= find_inherited_value(:hash_generator_proc)
      end

      def verify_http_method=(verify)
        query_analyzer(prepare_analyzer) if verify
      end

      def persisted_queries_tracing_enabled?
        @persisted_queries_tracing_enabled ||=
          find_inherited_value(:persisted_queries_tracing_enabled?)
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

      def prepare_analyzer
        if using_ast_analysis?
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
