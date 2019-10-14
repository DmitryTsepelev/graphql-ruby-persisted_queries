# frozen_string_literal: true

require "digest"

module GraphQL
  module PersistedQueries
    # Fetches or stores query string in the storage
    class Resolver
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

      def initialize(extensions, store)
        @extensions = extensions
        @store = store
      end

      def resolve(query_str)
        return query_str if hash.nil?

        if query_str
          persist_query(query_str)
        else
          query_str = @store.fetch_query(hash)
          raise NotFound if query_str.nil?
        end

        query_str
      end

      private

      def persist_query(query_str)
        raise WrongHash if Digest::SHA256.hexdigest(query_str) != hash

        @store.save_query(hash, query_str)
      end

      def hash
        @hash ||= @extensions.dig("persistedQuery", "sha256Hash")
      end
    end
  end
end
