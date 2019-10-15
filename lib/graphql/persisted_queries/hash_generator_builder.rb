# frozen_string_literal: true

require "digest"

module GraphQL
  module PersistedQueries
    # Builds hash generator
    class HashGeneratorBuilder
      def initialize(generator)
        @generator = generator
      end

      def build
        if @generator.is_a?(Proc)
          build_from_proc
        else
          build_from_name
        end
      end

      private

      def build_from_proc
        if @generator.arity != 1
          raise ArgumentError, "proc passed to :hash_generator should have exactly one argument"
        end

        @generator
      end

      def build_from_name
        upcased_name = @generator.to_s.upcase
        digest_class = Digest.const_get(upcased_name)
        proc { |value| digest_class.hexdigest(value) }
      rescue LoadError => e
        raise NameError, "digest class for :#{@generator} haven't been found", e.backtrace
      end
    end
  end
end
