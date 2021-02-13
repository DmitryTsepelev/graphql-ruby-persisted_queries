# frozen_string_literal: true

module GraphQL
  module CompiledQueries
    # Patches GraphQL::Execution::Multiplex to support compiled queries
    module MultiplexPatch
      def begin_query(query, multiplex)
        if query.persisted_query_not_found?
          query.context.errors << GraphQL::ExecutionError.new("PersistedQueryNotFound")
          GraphQL::Execution::Multiplex::NO_OPERATION
        else
          super
        end
      end
    end
  end
end
