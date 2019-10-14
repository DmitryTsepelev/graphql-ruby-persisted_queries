# GraphQL::PersistedQueries [![Build Status](https://travis-ci.org/DmitryTsepelev/graphql-ruby-persisted_queries.svg?branch=master)](https://travis-ci.org/DmitryTsepelev/graphql-ruby-persisted_queries)


`GraphQL::PersistedQueries` is the implementation of [persisted queries](https://github.com/apollographql/apollo-link-persisted-queries) for [graphql-ruby](https://github.com/rmosolgo/graphql-ruby). With this plugin your backend will cache all the queries, while frontend will send the full query only when it's not found at the backend storage.

- 🗑**Heavy query parameter will be omitted in most of cases** – network requests will become less heavy
- 🤝**Clients share** – it's enough to miss cache only once for each unique query
- 🎅**Works with clients without persisted query support**


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

4. Configure store if needed (`memory` is a default, `redis` is also supported)

```ruby
class GraphqlSchema < GraphQL::Schema
  use GraphQL::PersistedQueries,
      store: :redis,
      redis_url: ENV["REDIS_URL"]
end
```

5. Pass `:extensions` argument to all calls of `GraphqlSchema#execute` (start with `GraphqlController` and `GraphqlChannel`)

```ruby
GraphqlSchema.execute(
  params[:query],
  variables: ensure_hash(params[:variables]),
  context: {},
  operation_name: params[:operationName],
  extensions: params[:extensions]
)
```

6. Run the app! 🔥

## Contributing

Bug reports and pull requests are welcome on GitHub at https://github.com/DmitryTsepelev/graphql-persisted_queries.

## License

The gem is available as open source under the terms of the [MIT License](https://opensource.org/licenses/MIT).
