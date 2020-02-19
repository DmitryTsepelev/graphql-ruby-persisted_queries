# frozen_string_literal: true

require "graphql/persisted_queries/hash_generator_builder"
require "graphql/persisted_queries/resolver"

module GraphQL
  module PersistedQueries
    # Patches GraphQL::Schema to support persisted queries
    module SchemaPatch
      attr_reader :persisted_query_store, :hash_generator_proc, :persisted_query_error_handler

      def configure_persisted_query_store(store, options)
        @persisted_query_store = StoreAdapters.build(store, options)
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

      def execute(query_str = nil, **kwargs)
        if (extensions = kwargs.delete(:extensions))
          resolver = Resolver.new(extensions, persisted_query_store, hash_generator_proc,
                                  persisted_query_error_handler)
          query_str = resolver.resolve(query_str)
        end

        super
      rescue Resolver::NotFound, Resolver::WrongHash => e
        { errors: [{ message: e.message }] }
      end
    end
  end
end
