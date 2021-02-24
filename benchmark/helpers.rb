FIELD_COUNTS = [10, 50, 100, 200, 300]

def generate_fields(field_count, with_nested)
  fields = field_count.times.map do |i|
    field = "field#{i+1}"
    field += "\s{#{generate_fields(field_count, false)}}" if with_nested
    field
  end

  fields.join("\n")
end

def generate_query(field_count, with_nested)
  <<-gql
    query {
      #{generate_fields(field_count, with_nested)}
    }
  gql
end

class ChildType < GraphQL::Schema::Object
  FIELD_COUNTS.max.times do |i|
    field "field#{i + 1}".to_sym, String, null: false, method: :itself
  end
end

class QueryType < GraphQL::Schema::Object
  FIELD_COUNTS.max.times do |i|
    field "field#{i + 1}".to_sym, ChildType, null: false, method: :itself
  end
end
