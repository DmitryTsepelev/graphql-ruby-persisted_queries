# frozen_string_literal: true

module GraphQL
  module PersistedQueries
    # Helper functions for resolvers
    module ResolverHelpers
      module_function

      def with_error_handling
        yield
      rescue StandardError => e
        @schema.persisted_query_error_handler.call(e)
      end

      def validate_hash!(query_string)
        return if @schema.hash_generator_proc.call(query_string) == hash

        raise GraphQL::PersistedQueries::WrongHash
      end

      def hash
        @hash ||= @extensions.dig("persistedQuery", "sha256Hash")
      end
    end
  end
end
