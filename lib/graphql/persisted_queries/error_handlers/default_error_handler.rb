# frozen_string_literal: true

module GraphQL
  module PersistedQueries
    module ErrorHandlers
      # Default error handler for simply re-raising the error
      class DefaultErrorHandler < BaseErrorHandler
        def call(error)
          raise error
        end
      end
    end
  end
end
