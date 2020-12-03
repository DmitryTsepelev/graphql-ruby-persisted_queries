# frozen_string_literal: true

require "graphql/persisted_queries/error_handlers/base_error_handler"
require "graphql/persisted_queries/error_handlers/default_error_handler"

module GraphQL
  module PersistedQueries
    # Contains factory methods for error handlers
    module ErrorHandlers
      def self.build(handler, **options)
        if handler.is_a?(ErrorHandlers::BaseErrorHandler)
          handler
        elsif handler.is_a?(Proc)
          build_from_proc(handler)
        else
          build_by_name(handler, **options)
        end
      end

      def self.build_from_proc(proc)
        if proc.arity != 1
          raise ArgumentError, "proc passed to :error_handler should have exactly one argument"
        end

        proc
      end

      def self.build_by_name(name, **options)
        const_get("#{BuilderHelpers.camelize(name)}ErrorHandler").new(**options)
      rescue NameError => e
        raise e.class, "Persisted query error handler for :#{name} haven't been found", e.backtrace
      end
    end
  end
end
