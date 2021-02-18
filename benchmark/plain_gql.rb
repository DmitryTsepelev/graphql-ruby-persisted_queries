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
  query QueryType
end

GraphqlSchema.to_definition

puts "Plain schema:"
puts

Benchmark.bm(28) do |x|
  [false, true].each do |with_nested|
    FIELD_COUNTS.each do |field_count|
      query = generate_query(field_count, with_nested)

      x.report("#{field_count} fields#{" (nested)" if with_nested}") do
        GraphqlSchema.execute(query)
      end
    end
  end
end
