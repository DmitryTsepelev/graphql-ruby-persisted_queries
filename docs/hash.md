# Alternative hash functions

[apollo-link-persisted-queries](https://github.com/apollographql/apollo-link-persisted-queries) uses _SHA256_ by default so this gem uses it as a default too, but if you want to override it – you can use `:hash_generator` option:

```ruby
class GraphqlSchema < GraphQL::Schema
  use GraphQL::PersistedQueries, hash_generator: :md5
end
```

If string or symbol is passed – the gem would try to find the class in the `Digest` namespace. Altenatively, you  can pass a lambda, e.g.:

```ruby
class GraphqlSchema < GraphQL::Schema
  use GraphQL::PersistedQueries, hash_generator: proc { |_value| "super_safe_hash!!!" }
end
```
