# frozen_string_literal: true

module GraphQL
  module PersistedQueries
    module Analyzers
      # Verifies that mutations are not executed using GET requests
      class HttpMethodAstAnalyzer < GraphQL::Analysis::AST::Analyzer
        def initialize(query)
          super
          @query = query
        end

        def result
          HttpMethodValidator.new(@query).perform
        end
      end
    end
  end
end
