# frozen_string_literal: true

require "graphql/persisted_queries/hash_generator_builder"
require "graphql/persisted_queries/resolver"

module GraphQL
  module PersistedQueries
    # Patches GraphQL::Schema to support persisted queries
    module SchemaPatch
      attr_reader :persisted_query_store, :hash_generator_proc

      def configure_persisted_query_store(store, options)
        @persisted_query_store = StoreAdapters.build(store, options)
      end

      def hash_generator=(hash_generator)
        @hash_generator_proc = HashGeneratorBuilder.new(hash_generator).build
      end

      def execute(query_str = nil, **kwargs)
        if (extensions = kwargs.delete(:extensions))
          resolver = Resolver.new(extensions, persisted_query_store, hash_generator_proc, tracers: tracers)
          query_str = resolver.resolve(query_str)
        end

        super
      rescue Resolver::NotFound, Resolver::WrongHash => e
        { errors: [{ message: e.message }] }
      end
    end
  end
end
