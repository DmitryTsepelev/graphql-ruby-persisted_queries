require "bundler/inline"

gemfile do
  source "https://rubygems.org"
  gem "graphql", "1.12.4"
end

$:.push File.expand_path("../lib", __dir__)

require "benchmark"
require "graphql/persisted_queries"
require_relative "helpers"

class GraphqlSchema < GraphQL::Schema
  use GraphQL::PersistedQueries, compiled_queries: true

  query QueryType
end

class GraphqlSchemaWithoutMarshalling < GraphQL::Schema
  use GraphQL::PersistedQueries, compiled_queries: true, marshal_inmemory_queries: false

  query QueryType
end

GraphqlSchema.to_definition

puts
puts "Schema with compiled queries:"
puts

Benchmark.bm(28) do |x|
  [false, true].each do |with_nested|
    FIELD_COUNTS.each do |field_count|
      query = generate_query(field_count, with_nested)
      sha256 = Digest::SHA256.hexdigest(query)

      context = { extensions: { "persistedQuery" => { "sha256Hash" => sha256 } } }
      # warmup
      GraphqlSchema.execute(query, context: context)
      GraphqlSchemaWithoutMarshalling.execute(query, context: context)

      x.report("#{field_count} fields#{' (nested)' if with_nested} (marshalled)") do
        GraphqlSchema.execute(query, context: context)
      end

      x.report("#{field_count} fields#{' (nested)' if with_nested}") do
        GraphqlSchemaWithoutMarshalling.execute(query, context: context)
      end
    end
  end
end
