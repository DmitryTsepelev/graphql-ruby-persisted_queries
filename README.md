# GraphQL::PersistedQueries ![](https://ruby-gem-downloads-badge.herokuapp.com/graphql-persisted_queries?type=total)

`GraphQL::PersistedQueries` is the implementation of [persisted queries](https://www.apollographql.com/docs/react/api/link/persisted-queries/) for [graphql-ruby](https://github.com/rmosolgo/graphql-ruby). With this plugin your backend will cache all the queries, while frontend will send the full query only when it's not found at the backend storage.

- 🗑**Heavy query parameter will be omitted in most of cases** – network requests will become less heavy
- 🤝**Clients share cached queries** – it's enough to miss cache only once for each unique query
- 🎅**Works for clients without persisted query support**

Used in production by:

- [Yammer by Microsoft](https://github.com/DmitryTsepelev/graphql-ruby-persisted_queries/issues/20#issuecomment-587945989)
- Toptal
- _Want to be here? Let me know_ 🙂

## Getting started

First of all, install and configure [apollo's persisted queries](https://www.apollographql.com/docs/react/api/link/persisted-queries/) on the front–end side:

```js
import { HttpLink, InMemoryCache, ApolloClient } from "@apollo/client";
import { createPersistedQueryLink } from "@apollo/client/link/persisted-queries";
import { sha256 } from 'crypto-hash';

const httpLink = new HttpLink({ uri: "/graphql" });
const persistedQueriesLink = createPersistedQueryLink({ sha256 });
const client = new ApolloClient({
  cache: new InMemoryCache(),
  link: persistedQueriesLink.concat(httpLink);
});
```

Add the gem to your Gemfile `gem 'graphql-persisted_queries'` and add the plugin to your schema class:

```ruby
class GraphqlSchema < GraphQL::Schema
  use GraphQL::PersistedQueries
end
```

Pass `:extensions` argument as part of a `context` to all calls of `GraphqlSchema#execute`, usually it happens in `GraphqlController`, `GraphqlChannel` and tests:

```ruby
GraphqlSchema.execute(
  params[:query],
  variables: ensure_hash(params[:variables]),
  context: {
    extensions: ensure_hash(params[:extensions])
  },
  operation_name: params[:operationName]
)
```

You're all set!

## Compiled queries (increases performance up to 2x!)

When query arrives to the backend, GraphQL execution engine needs some time to _parse_ it and build the AST. In case of a huge query it might take [a lot](https://gist.github.com/DmitryTsepelev/36e290cf64b4ec0b18294d0a57fb26ff#file-1_result-md) of time. What if we cache the AST instead of a query text and skip parsing completely? The only thing you need to do is to turn `:compiled_queries` option on:

```ruby
class GraphqlSchema < GraphQL::Schema
  use GraphQL::PersistedQueries, compiled_queries: true
end
```

Using this option might make your endpoint up to 2x faster according to the [benchmark](docs/compiled_queries_benchmark.md).

**Heads up!** This feature only works on `graphql-ruby` 1.12.0 or later, but I guess it might be backported.

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

[batch-link](https://www.apollographql.com/docs/react/api/link/apollo-link-batch-http/) allows to group queries on the client side into a single HTTP request before sending to the server. In this case you need to use `GraphqlSchema.multiplex(queries)` instead of `#execute`. The gem supports it too, no action required!

[persisted-queries-link](https://www.apollographql.com/docs/react/api/link/persisted-queries/) uses _SHA256_ for building hashes by default. Check out this [guide](docs/hash.md) if you want to override this behavior.

It is possible to skip some parts of the query lifecycle for cases when query is persisted—read more [here](docs/skip_query_preprocessing).

An experimental tracing feature can be enabled by setting `tracing: true` when configuring the plugin. Read more about this feature in the [Tracing guide](docs/tracing.md).

> 📖 Read more about the gem internals: [Persisted queries in GraphQL:
Slim down Apollo requests to your Ruby application](https://evilmartians.com/chronicles/persisted-queries-in-graphql-slim-down-apollo-requests-to-your-ruby-application)

## Credits

Initially sponsored by [Evil Martians](http://evilmartians.com).

## Contributing

Bug reports and pull requests are welcome on GitHub at https://github.com/DmitryTsepelev/graphql-ruby-persisted_queries.

## License

The gem is available as open source under the terms of the [MIT License](https://opensource.org/licenses/MIT).
