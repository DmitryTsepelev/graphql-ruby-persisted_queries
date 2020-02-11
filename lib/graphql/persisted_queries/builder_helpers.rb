# frozen_string_literal: true

module GraphQL
  module PersistedQueries
    # Contains factory methods for error handlers
    module BuilderHelpers
      def self.camelize(name)
        name.to_s.split("_").map(&:capitalize).join
      end
    end
  end
end
