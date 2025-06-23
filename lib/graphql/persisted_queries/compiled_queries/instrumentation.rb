# frozen_string_literal: true

module GraphQL
  module PersistedQueries
    module CompiledQueries
      # Instrumentation to support compiled queries
      module Instrumentation
        class << self
          # Actions to perform before the query resolution
          def before_query(query)
            query = query.query if query.class.name == "GraphQL::Query::Partial" # rubocop:disable Style/ClassEqualityComparison

            return unless query.context[:extensions]

            query.try_load_document!
            return if query.document || query.query_string

            query.persisted_query_not_found!
            query.context.errors << GraphQL::ExecutionError.new(NotFound::MESSAGE)
          end

          def after_query(*); end
        end

        # Instrumentations were deprecated in 2.2.5, this is a module to migrate to new interface
        module Tracer
          def execute_query(query:)
            GraphQL::PersistedQueries::CompiledQueries::Instrumentation.before_query(query)
            super
          end

          def execute_multiplex(multiplex:)
            multiplex.queries.each do |query|
              GraphQL::PersistedQueries::CompiledQueries::Instrumentation.before_query(query)
            end

            super
          end
        end
      end
    end
  end
end
