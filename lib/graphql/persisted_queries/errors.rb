# frozen_string_literal: true

module GraphQL
  module PersistedQueries
    # Raised when persisted query is not found in the storage
    class NotFound < StandardError
      def message
        "PersistedQueryNotFound"
      end
    end

    # Raised when provided hash is not matched with query
    class WrongHash < StandardError
      def message
        "Wrong hash was passed"
      end
    end
  end
end
