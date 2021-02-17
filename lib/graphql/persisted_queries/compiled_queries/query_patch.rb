# frozen_string_literal: true

module GraphQL
  module PersistedQueries
    module CompiledQueries
      # Patches GraphQL::Query to support compiled queries
      module QueryPatch
        def persisted_query_not_found?
          @persisted_query_not_found
        end

        def prepare_ast
          @document = resolver.fetch
          not_loaded_document = @document.nil?

          @persisted_query_not_found = not_loaded_document && query_string.nil?

          super.tap do
            resolver.persist(query_string, @document) if not_loaded_document && query_string
          end
        end

        private

        def resolver
          @resolver ||= Resolver.new(@schema, @context[:extensions])
        end
      end
    end
  end
end
