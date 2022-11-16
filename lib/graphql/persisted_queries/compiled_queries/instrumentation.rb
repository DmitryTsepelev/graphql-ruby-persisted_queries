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

            query.try_load_document!
            return if query.document || query.query_string

            query.persisted_query_not_found!
            query.context.errors << GraphQL::ExecutionError.new(NotFound::MESSAGE)
          end

          def after_query(*); end
        end
      end
    end
  end
end
