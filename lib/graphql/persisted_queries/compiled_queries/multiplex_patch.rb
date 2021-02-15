# frozen_string_literal: true

module GraphQL
  module PersistedQueries
    module CompiledQueries
      # Patches GraphQL::Execution::Multiplex to support compiled queries
      module MultiplexPatch
        # 1.12.0-1.12.3
        # def begin_query(query, multiplex)
        #   if query.persisted_query_not_found?
        #     query.context.errors << GraphQL::ExecutionError.new("PersistedQueryNotFound")
        #     return GraphQL::Execution::Multiplex::NO_OPERATION
        #   end
        #
        #   super
        # end

        # 1.12.4
        def begin_query(results, idx, query, multiplex)
          if query.persisted_query_not_found?
            query.context.errors << GraphQL::ExecutionError.new("PersistedQueryNotFound")
            results[idx] = NO_OPERATION
            return
          end

          super
        end
      end
    end
  end
end
