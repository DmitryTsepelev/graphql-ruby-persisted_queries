# frozen_string_literal: true

module GraphQL
  module PersistedQueries
    # Verifies that mutations are not executed using GET requests
    class HttpMethodAnalyzer
      def analyze?(query)
        query.context[:request]
      end

      def initial_value(query)
        {
          get_request: query.context[:request]&.get?,
          mutation: query.mutation?
        }
      end

      def call(memo, _visit_type, _irep_node)
        memo
      end

      def final_value(memo)
        return if !memo[:get_request] || !memo[:mutation]

        GraphQL::AnalysisError.new("Mutations cannot be performed via HTTP GET")
      end
    end
  end
end
