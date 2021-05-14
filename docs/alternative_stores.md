# Alternative stores

We currently support a few different stores that can be configured out of the box:

- `:memory`: This is the default in-memory store and is great for getting started, but will require each instance to cache results independently which can result in lots of ["new query path"](https://blog.apollographql.com/improve-graphql-performance-with-automatic-persisted-queries-c31d27b8e6ea) requests.
- `:redis`: This store will allow you to share a Redis cache across all instances of your GraphQL application so that each instance doesn't have to ask the client for the query again if it hasn't seen it yet.
- `:redis_with_local_cache`: This store combines both the `:memory` and `:redis` approaches so that we can reduce the number of network requests we make while mitigating the independent cache issue.  This adapter is configured identically to the `:redis` store.
- `:memcached`: This store will allow you to share a Memcached cache across all instances of your GraphQL application. The client is implemented with the Dalli gem.

## Redis

If you have `ENV["REDIS_URL"]` configured – you don't need to pass it explicitly. Also, you can pass `:redis_host`, `:redis_port` and `:redis_db_name`
inside the `:redis_client` hash to build the URL from scratch or pass the configured `Redis` or `ConnectionPool` object:

```ruby
class GraphqlSchema < GraphQL::Schema
  use GraphQL::PersistedQueries,
      store: :redis,
      redis_client: { redis_host: "127.0.0.2", redis_port: "2214", redis_db_name: "7" }
  # or
  use GraphQL::PersistedQueries,
      store: :redis,
      redis_client: Redis.new(url: "redis://127.0.0.2:2214/7")
  # or
  use GraphQL::PersistedQueries,
      store: :redis,
      redis_client: ConnectionPool.new { Redis.new(url: "redis://127.0.0.2:2214/7") }
  # or with ENV["REDIS_URL"]
  use GraphQL::PersistedQueries,
      store: :redis
end
```

You can also pass options for expiration and namespace to override the defaults:

```ruby
class GraphqlSchema < GraphQL::Schema
  use GraphQL::PersistedQueries,
      store: :redis,
      redis_client: { redis_url: ENV["MY_REDIS_URL"] },
      expiration: 172800, # optional, default is 24 hours
      namespace: "my-custom-namespace" # optional, default is "graphql-persisted-query"
end
```

## Memcached

If you have `ENV["MEMCACHE_SERVERS"]` configured - you don't need to pass it explicitly. Also, you can pass `:memcached_host` and `:memcached_port`
inside the `:dalli_client` hash to build the server name from scratch or pass the configured `Dalli::Client` object:

```ruby
class GraphqlSchema < GraphQL::Schema
  use GraphQL::PersistedQueries,
      store: :memcached,
      dalli_client: { memcached_host: "127.0.0.2", memcached_port: "11211" }
  # or
  use GraphQL::PersistedQueries,
      store: :memcached,
      dalli_client: Dalli::Client.new("127.0.0.2:11211")
  # or
  use GraphQL::PersistedQueries,
      store: :memcached,
      dalli_client: { memcached_url: "127.0.0.2:11211" }
end
```

You can also pass options for `expiration` and `namespace` to override the defaults.
Any additional argument inside `dalli_client` will be forwarded to `Dalli::Client.new`.
Following example configures Dalli `pool_size` and `compress` options:

```ruby
class GraphqlSchema < GraphQL::Schema
  use GraphQL::PersistedQueries,
      store: :memcached,
      dalli_client: {
        memcached_url: "127.0.0.2:11211",
        pool_size: 5,
        compress: true
      },
      expiration: 172800, # optional, default is 24 hours
      namespace: "my-custom-namespace" # optional, default is "graphql-persisted-query"
end
```
