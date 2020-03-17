# frozen_string_literal: true

module GraphQL
  module PersistedQueries
    module Analyzers
      # Verifies that mutations are not executed using GET requests
      class HttpMethodValidator
        def initialize(query)
          @query = query
        end

        def perform
          return if !@query.context[:request]&.get? || !@query.mutation?

          GraphQL::AnalysisError.new("Mutations cannot be performed via HTTP GET")
        end
      end
    end
  end
end
