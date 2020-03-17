# frozen_string_literal: true

module GraphQL
  module PersistedQueries
    module Analyzers
      # Verifies that mutations are not executed using GET requests
      class HttpMethodAnalyzer
        def initial_value(query)
          { query: query }
        end

        def call(memo, _visit_type, _irep_node)
          memo
        end

        def final_value(memo)
          HttpMethodValidator.new(memo[:query]).perform
        end
      end
    end
  end
end
