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

## Getting started

First of all, install and configure [apollo-link-persisted-queries](https://github.com/apollographql/apollo-link-persisted-queries) on the front–end side:

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

Add the gem to your Gemfile `gem 'graphql-persisted_queries'` and add the plugin to your schema class:

```ruby
class GraphqlSchema < GraphQL::Schema
  use GraphQL::PersistedQueries
end
```

Pass `:extensions` argument to all calls of `GraphqlSchema#execute`, usually it happens in `GraphqlController`, `GraphqlChannel` and tests.

```ruby
GraphqlSchema.execute(
  params[:query],
  variables: ensure_hash(params[:variables]),
  context: {},
  operation_name: params[:operationName],
  extensions: ensure_hash(params[:extensions])
)
```

You're all set!

## Advanced usage

All the queries are stored in memory by default, but you can easily switch to another storage (e.g., _redis_:

```ruby
class GraphqlSchema < GraphQL::Schema
  use GraphQL::PersistedQueries, store: :redis, redis_client: { redis_url: ENV["MY_REDIS_URL"] }
end
```

We currently support `memory`, `redis`, `redis_with_local_cache` and `memcached` out of the box. The detailed documentation can be found [here](docs/alternative_stores.md).

When the error occurs, the gem tries to not interrupt the regular flow of the app (e.g., when something is wrong with the storage, it will just answer that persisted query is not found). You can add a [custom](docs/error_handling.md) error handler and try to fix the problem or just log it.

Since our queries are slim now, we can switch back to HTTP GET, you can find a [guide](docs/http_cache.md) here.

[batch-link](https://www.apollographql.com/docs/link/links/batch-http/) allows to group queries on the client side into a single HTTP request before sending to the server. In this case you need to use `GraphqlSchema.multiplex(queries)` instead of `#execute`. The gem supports it too, no action required!

[apollo-link-persisted-queries](https://github.com/apollographql/apollo-link-persisted-queries) uses _SHA256_ for building hashes by default. Check out this [guide](docs/hash.md) if you want to override this behavior.

An experimental tracing feature can be enabled by setting `tracing: true` when configuring the plugin. Read more about this feature in the [Tracing guide](docs/tracing.md).

> 📖 Read more about the gem internals: [Persisted queries in GraphQL:
Slim down Apollo requests to your Ruby application](https://evilmartians.com/chronicles/persisted-queries-in-graphql-slim-down-apollo-requests-to-your-ruby-application)

## Contributing

Bug reports and pull requests are welcome on GitHub at https://github.com/DmitryTsepelev/graphql-ruby-persisted_queries.

## License

The gem is available as open source under the terms of the [MIT License](https://opensource.org/licenses/MIT).
