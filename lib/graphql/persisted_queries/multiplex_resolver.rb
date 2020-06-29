# frozen_string_literal: true

module GraphQL
  module PersistedQueries
    # Resolves multiplex query
    class MultiplexResolver
      def initialize(schema, queries, kwargs)
        @schema = schema
        @queries = queries
        @kwargs = kwargs
      end

      def resolve
        resolve_persisted_queries
        perform_multiplex
        results
      end

      private

      def results
        @results ||= Array.new(@queries.count)
      end

      def resolve_persisted_queries
        @queries.each_with_index do |query_params, i|
          resolve_persisted_query(query_params, i)
        end
      end

      def resolve_persisted_query(query_params, pos)
        extensions = query_params.dig(:context, :extensions)
        return unless extensions

        query_params[:query] = Resolver.new(extensions, @schema).resolve(query_params[:query])
      rescue Resolver::NotFound, Resolver::WrongHash => e
        values = { "errors" => [{ "message" => e.message }] }
        results[pos] = GraphQL::Query::Result.new(query: GraphQL::Query.new(@schema, query_params[:query]), values: values)
      end

      def perform_multiplex
        resolve_idx = (0...@queries.count).select { |i| results[i].nil? }
        multiplex_result = @schema.multiplex_original(
          resolve_idx.map { |i| @queries.at(i) }, @kwargs
        )
        resolve_idx.each_with_index { |res_i, mult_i| results[res_i] = multiplex_result[mult_i] }
      end
    end
  end
end
