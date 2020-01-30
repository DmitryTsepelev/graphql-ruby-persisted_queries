# frozen_string_literal: true

module GraphQL
  module PersistedQueries
    module ErrorHandlers
      # Base class for all error handlers
      class BaseErrorHandler
        def initialize(_options); end

        def call(_error)
          raise NotImplementedError
        end
      end
    end
  end
end
