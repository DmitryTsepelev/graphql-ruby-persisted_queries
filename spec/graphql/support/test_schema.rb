# frozen_string_literal: true

# rubocop:disable Metrics/MethodLength
def build_test_schema(options = {})
  test_tracer = options.delete(:tracer)
  schema = Class.new(GraphQL::Schema) do
    use GraphQL::PersistedQueries, options
    tracer test_tracer if test_tracer

    query(
      Class.new(GraphQL::Schema::Object) do
        graphql_name "Query"

        field :some_data, String, null: false
        field :some_other_data, String, null: false

        def some_data
          "some value"
        end

        def some_other_data
          "some other value"
        end
      end
    )
  end

  if Gem::Dependency.new("graphql", "<= 1.10.0").match?("graphql", GraphQL::VERSION)
    schema.graphql_definition
  else
    schema
  end
end
# rubocop:enable Metrics/MethodLength
