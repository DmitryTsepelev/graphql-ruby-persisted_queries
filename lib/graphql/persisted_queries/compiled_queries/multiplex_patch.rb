# frozen_string_literal: true

module GraphQL
  module PersistedQueries
    module CompiledQueries
      # Patches GraphQL::Execution::Multiplex to support compiled queries
      module MultiplexPatch
        if Gem::Dependency.new("graphql", ">= 1.12.4").match?("graphql", GraphQL::VERSION)
          def begin_query(results, idx, query, multiplex)
            return super unless query.persisted_query_not_found?

            results[idx] = add_not_found_error(query)
          end
        else
          def begin_query(query, multiplex)
            return super unless query.persisted_query_not_found?

            add_not_found_error(query)
          end
        end

        def add_not_found_error(query)
          query.context.errors.clear
          query.context.errors << GraphQL::ExecutionError.new(NotFound::MESSAGE)
          GraphQL::Execution::Multiplex::NO_OPERATION
        end
      end
    end
  end
end
