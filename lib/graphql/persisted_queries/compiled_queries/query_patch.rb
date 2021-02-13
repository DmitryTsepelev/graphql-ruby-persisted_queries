# frozen_string_literal: true

module GraphQL
  module CompiledQueries
    # Patches GraphQL::Query to support compiled queries
    module QueryPatch
      def persisted_query_not_found?
        @persisted_query_not_found
      end

      def prepare_ast
        try_fetch_query if persisted_query_hash
        super.tap { persist_compiled_query }
      end

      private

      def try_fetch_query
        compiled_query = @schema.persisted_query_store.fetch_query(
          persisted_query_hash, compiled_query: true
        )

        if compiled_query
          @document = Marshal.load(compiled_query) # rubocop:disable Security/MarshalLoad
        else
          @persisted_query_not_found = query_string.nil?
        end
      end

      def persist_compiled_query
        return if persisted_query_hash.nil? || persisted_query_not_found?

        @schema.persisted_query_store.save_query(
          persisted_query_hash, Marshal.dump(@document), compiled_query: true
        )
      end

      def persisted_query_hash
        @persisted_query_hash ||= (@context[:extensions] || {}).dig("persistedQuery", "sha256Hash")
      end
    end
  end
end
