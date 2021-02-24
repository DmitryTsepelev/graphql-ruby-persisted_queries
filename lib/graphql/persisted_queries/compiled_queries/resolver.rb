# frozen_string_literal: true

module GraphQL
  module PersistedQueries
    module CompiledQueries
      # Fetches and persists compiled query
      class Resolver
        include GraphQL::PersistedQueries::ResolverHelpers

        def initialize(schema, extensions)
          @schema = schema
          @extensions = extensions
        end

        def fetch
          return if hash.nil?

          with_error_handling do
            compiled_query = @schema.persisted_query_store.fetch_query(hash, compiled_query: true)
            Marshal.load(compiled_query) if compiled_query # rubocop:disable Security/MarshalLoad
          end
        end

        def persist(query_string, compiled_query)
          return if hash.nil?

          validate_hash!(query_string)

          with_error_handling do
            @schema.persisted_query_store.save_query(
              hash, Marshal.dump(compiled_query), compiled_query: true
            )
          end
        end
      end
    end
  end
end
