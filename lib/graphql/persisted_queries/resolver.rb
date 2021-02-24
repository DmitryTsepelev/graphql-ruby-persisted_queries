# frozen_string_literal: true

module GraphQL
  module PersistedQueries
    # Fetches or stores query string in the storage
    class Resolver
      include GraphQL::PersistedQueries::ResolverHelpers

      def initialize(extensions, schema)
        @extensions = extensions
        @schema = schema
      end

      def resolve(query_string)
        return query_string if hash.nil?

        if query_string
          persist_query(query_string)
        else
          query_string = with_error_handling { @schema.persisted_query_store.fetch_query(hash) }
          raise GraphQL::PersistedQueries::NotFound if query_string.nil?
        end

        query_string
      end

      private

      def persist_query(query_string)
        validate_hash!(query_string)

        with_error_handling { @schema.persisted_query_store.save_query(hash, query_string) }
      end
    end
  end
end
