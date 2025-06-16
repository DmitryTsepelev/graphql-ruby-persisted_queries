# frozen_string_literal: true

module GraphQL
  module PersistedQueries
    module CompiledQueries
      # Fetches and persists compiled query
      class Resolver
        include GraphQL::PersistedQueries::ResolverHelpers

        # Patch to support custom serialization
        class GraphQL::Language::Parser # rubocop:disable Style/ClassAndModuleChildren
          SEP = "|"

          def _dump(*)
            [
              @graphql_str,
              JSON.generate("filename": @filename, "max_tokens": @max_tokens, "document": @document)
            ].join(SEP)
          end

          def self._load(args)
            graphql_str, raw_kwargs = args.split(SEP)

            new(graphql_str,
                filename: raw_kwargs["filename"],
                max_tokens: raw_kwargs["max_tokens"]).tap do |parser|
              parser.instance_variable_set(:@document, raw_kwargs["document"])
            end
          end
        end

        def initialize(schema, extensions)
          @schema = schema
          @extensions = extensions
        end

        def fetch
          return if hash.nil?

          with_error_handling do
            @schema.persisted_query_store.fetch_query(hash, compiled_query: true)
          end
        end

        def persist(query_string, compiled_query)
          return if hash.nil?

          validate_hash!(query_string)

          with_error_handling do
            @schema.persisted_query_store.save_query(
              hash, compiled_query, compiled_query: true
            )
          end
        end
      end
    end
  end
end
