require "bundler/inline"

gemfile do
  source "https://rubygems.org"
  gem "graphql", "1.12.4"
end

$:.push File.expand_path("../lib", __dir__)

require "benchmark"
require "graphql/persisted_queries"
require_relative "helpers"

FIELD_COUNTS = [10, 100, 200, 300]

class GraphqlSchema < GraphQL::Schema
  use GraphQL::PersistedQueries, compiled_queries: true

  query QueryType
end

GraphqlSchema.to_definition

puts
puts "Schema with compiled queries:"
puts

Benchmark.bm(28) do |x|
  [0, 1].each do |nesting_level|
    FIELD_COUNTS.each do |field_count|
      query = generate_query(field_count, nesting_level)
      sha256 = Digest::SHA256.hexdigest(query)

      context = { extensions: { "persistedQuery" => { "sha256Hash" => sha256 } } }
      # warmup
      GraphqlSchema.execute(query, context: context)

      x.report("#{field_count} fields, #{nesting_level} nested levels: ") do
        GraphqlSchema.execute(query, context: context)
      end
    end
  end
end
