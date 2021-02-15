FIELD_COUNTS = [10, 100, 200, 300]

def generate_fields(field_count, nesting_level, indent = 6)
  fields = field_count.times.map do |i|
    field = " " * indent + "field#{i+1}"
    if nesting_level > 0
      field += <<-gql
\s{
#{generate_fields(field_count, nesting_level - 1, indent + 2)}
#{" " * indent}}
      gql
    end
    field
  end

  fields.join("\n")
end

def generate_query(field_count, nesting_level)
  <<-gql
    query {
#{generate_fields(field_count, nesting_level)}
    }
  gql
end

class LeafType < GraphQL::Schema::Object
  FIELD_COUNTS.max.times do |i|
    field "field#{i + 1}".to_sym, String, null: false, resolver_method: :resolve_field
  end

  def resolve_field; "value"; end
end

class QueryType < GraphQL::Schema::Object
  FIELD_COUNTS.max.times do |i|
    field "field#{i + 1}".to_sym, LeafType, null: false, resolver_method: :resolve_field
  end

  def resolve_field; end
end
