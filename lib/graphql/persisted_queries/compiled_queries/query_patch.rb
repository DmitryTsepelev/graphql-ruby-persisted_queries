# frozen_string_literal: true

module GraphQL
  module PersistedQueries
    module CompiledQueries
      # Patches GraphQL::Query to support compiled queries
      module QueryPatch
        def persisted_query_not_found!
          @persisted_query_not_found = true
        end

        def persisted_query_not_found?
          @persisted_query_not_found
        end

        def prepare_ast
          return super if @context[:extensions].nil? || @document

          try_load_document!

          super.tap do
            if @context.errors.any?(&method(:not_found_error?))
              @context.errors.select!(&method(:not_found_error?))
            end

            if @persisted_document_not_found && query_string
              resolver.persist(query_string, @document)
            end
          end
        end

        def try_load_document!
          return if @document || @persisted_document_not_found

          compiled_query_resolver = CompiledQueries::Resolver.new(schema, context[:extensions])
          @document = compiled_query_resolver.fetch
          @persisted_document_not_found = @document.nil?
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
