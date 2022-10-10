# frozen_string_literal: true

module GraphQL
  module PersistedQueries
    module CompiledQueries
      # Instrumentation to support compiled queries
      module Instrumentation
        class << self
          # Actions to perform before the query resolution
          def before_query(query)
            return unless query.context[:extensions]

            resolver = resolver_for(query)
            if (document = resolver.fetch)
              query.fulfill_document(document)
            else
              query.not_loaded_document!
            end

            return if document || query.query_string

            query.persisted_query_not_found!
            query.context.errors << GraphQL::ExecutionError.new(NotFound::MESSAGE)
          end

          def after_query(*); end

          private

          def resolver_for(query)
            CompiledQueries::Resolver.new(query.schema, query.context[:extensions])
          end
        end
      end
    end
  end
end
