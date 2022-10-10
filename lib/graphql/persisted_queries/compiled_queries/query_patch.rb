# frozen_string_literal: true

module GraphQL
  module PersistedQueries
    module CompiledQueries
      # Patches GraphQL::Query to support compiled queries
      module QueryPatch
        def fulfill_document(document)
          @document = document
        end

        def not_loaded_document!
          @not_loaded_document = true
        end

        def persisted_query_not_found!
          @persisted_query_not_found = true
        end

        def persisted_query_not_found?
          @persisted_query_not_found
        end

        def prepare_ast
          return super unless @context[:extensions]

          super.tap do
            if @context.errors.any?(&method(:not_found_error?))
              @context.errors.select!(&method(:not_found_error?))
            end

            resolver.persist(query_string, @document) if @not_loaded_document && query_string
          end
        end

        private

        def resolver
          @resolver ||= Resolver.new(@schema, @context[:extensions])
        end

        def not_found_error?(error)
          error.message == GraphQL::PersistedQueries::NotFound::MESSAGE
        end
      end
    end
  end
end
