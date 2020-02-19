# GraphQL::PersistedQueries [![Build Status](https://travis-ci.org/DmitryTsepelev/graphql-ruby-persisted_queries.svg?branch=master)](https://travis-ci.org/DmitryTsepelev/graphql-ruby-persisted_queries)


`GraphQL::PersistedQueries` is the implementation of [persisted queries](https://github.com/apollographql/apollo-link-persisted-queries) for [graphql-ruby](https://github.com/rmosolgo/graphql-ruby). With this plugin your backend will cache all the queries, while frontend will send the full query only when it's not found at the backend storage.

- 🗑**Heavy query parameter will be omitted in most of cases** – network requests will become less heavy
- 🤝**Clients share cached queries** – it's enough to miss cache only once for each unique query
- 🎅**Works for clients without persisted query support**


<p align="center">
  <a href="https://evilmartians.com/?utm_source=graphql-ruby-persisted_queries">
    <img src="https://evilmartians.com/badges/sponsored-by-evil-martians.svg" alt="Sponsored by Evil Martians" width="236" height="54">
  </a>
</p>

## Installation

1. Add the gem to your Gemfile `gem 'graphql-persisted_queries'`

2. Install and configure [apollo-link-persisted-queries](https://github.com/apollographql/apollo-link-persisted-queries):

```js
import { createPersistedQueryLink } from "apollo-link-persisted-queries";
import { createHttpLink } from "apollo-link-http";
import { InMemoryCache } from "apollo-cache-inmemory";
import ApolloClient from "apollo-client";


// use this with Apollo Client
const link = createPersistedQueryLink().concat(createHttpLink({ uri: "/graphql" }));
const client = new ApolloClient({
  cache: new InMemoryCache(),
  link: link,
});
```

3. Add plugin to the schema:

```ruby
class GraphqlSchema < GraphQL::Schema
  use GraphQL::PersistedQueries
end
```

4. Pass `:extensions` argument to all calls of `GraphqlSchema#execute` (start with `GraphqlController` and `GraphqlChannel`)

```ruby
GraphqlSchema.execute(
  params[:query],
  variables: ensure_hash(params[:variables]),
  context: {},
  operation_name: params[:operationName],
  extensions: ensure_hash(params[:extensions])
)
```

5. Run the app! 🔥

## Alternative stores

All the queries are stored in memory by default, but you can easily switch to _redis_:

```ruby
class GraphqlSchema < GraphQL::Schema
  use GraphQL::PersistedQueries, store: :redis, redis_client: { redis_url: ENV["MY_REDIS_URL"] }
end
```

If you have `ENV["REDIS_URL"]` configured – you don't need to pass it explicitly. Also, you can pass `:redis_host`, `:redis_port` and `:redis_db_name` inside the `:redis_client` hash to build the URL from scratch or pass the configured `Redis` or `ConnectionPool` object:

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

### Supported stores

We currently support a few different stores that can be configured out of the box:

- `:memory`: This is the default in-memory store and is great for getting started, but will require each instance to cache results independently which can result in lots of ["new query path"](https://blog.apollographql.com/improve-graphql-performance-with-automatic-persisted-queries-c31d27b8e6ea) requests.
- `:redis`: This store will allow you to share a Redis cache across all instances of your GraphQL application so that each instance doesn't have to ask the client for the query again if it hasn't seen it yet.
- `:redis_with_local_cache`: This store combines both the `:memory` and `:redis` approaches so that we can reduce the number of network requests we make while mitigating the independent cache issue.  This adapter is configured identically to the `:redis` store.

## Alternative hash functions

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

## Error handling

You may optionally specify an object that will be called whenever an error occurs while attempting to resolve or save a query.  This will give you the opportunity to both handle (e.g. graceful Redis failure) and/or log the error.  By default, errors will be raised when a failure occurs within a `StoreAdapter`.

An error handler can be a proc or an implementation of `GraphQL::PersistedQueries::ErrorHandlers::BaseErrorHandler`.  Here's an example for treating Redis failures as cache misses:

```ruby
class GracefulRedisErrorHandler < GraphQL::PersistedQueries::ErrorHandlers::BaseErrorHandler
  def call(error)
    case error
    when Redis::BaseError
      # Treat Redis errors as a cache miss, but you should log the error into
      # your instrumentation framework here.
    else
      raise error
    end

    # Return nothing to ensure handled errors are treated as cache misses
    return
  end
end

class GraphqlSchema < GraphQL::Schema
  use GraphQL::PersistedQueries, error_handler: GracefulRedisErrorHandler.new
end
```

## GET requests and HTTP cache

Using `GET` requests for persisted queries allows you to enable HTTP caching (e.g., turn on CDN). This is how to turn them on:
1. Change the way link is initialized on front-end side (`createPersistedQueryLink({ useGETForHashedQueries: true })`);
2. Register a new route `get "/graphql", to: "graphql#execute"`;
3. Put the request object to the GraphQL context in the controller `GraphqlSchema.execute(query, variables: variables, context: { request: request })`;
4. Turn the `verify_http_method` option on (`use GraphQL::PersistedQueries, verify_http_method: true`) to enforce using `POST` requests for performing mutations (otherwise the error `Mutations cannot be performed via HTTP GET` will be returned).

HTTP method verification is important, because when mutations are allowed via `GET` requests, it's easy to perform an attack by sending the link containing mutation to a signed in user.

## Contributing

Bug reports and pull requests are welcome on GitHub at https://github.com/DmitryTsepelev/graphql-ruby-persisted_queries.

## License

The gem is available as open source under the terms of the [MIT License](https://opensource.org/licenses/MIT).
