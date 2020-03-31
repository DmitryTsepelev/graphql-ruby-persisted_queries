# GET requests and HTTP cache

Using `GET` requests for persisted queries allows you to enable HTTP caching (e.g., turn on CDN).

Firstly, turn on the `useGETForHashedQueries` parameter on the front-end side:

```js
import { createPersistedQueryLink } from "apollo-link-persisted-queries";
import { createHttpLink } from "apollo-link-http";
import { InMemoryCache } from "apollo-cache-inmemory";
import ApolloClient from "apollo-client";


// use this with Apollo Client
const link = createPersistedQueryLink({ useGETForHashedQueries: true }).concat(createHttpLink({ uri: "/graphql" }));
const client = new ApolloClient({
  cache: new InMemoryCache(),
  link: link,
});
```

Register a new route in `routes.rb`:

```ruby
get "/graphql", to: "graphql#execute"
```

Put the request object to the GraphQL context everywhere you execute GraphQL queries:

```ruby
GraphqlSchema.execute(
  query,
  variables: ensure_hash(params[:variables]),
  context: {
    extensions: ensure_hash(params[:extensions])
    request: request
  }
)
```

Turn the `verify_http_method` option when configuring the plugin to enforce using `POST` requests for performing mutations (otherwise the error `Mutations cannot be performed via HTTP GET` will be returned):

```ruby
class GraphqlSchema < GraphQL::Schema
  use GraphQL::PersistedQueries, verify_http_method: true
end
```

HTTP method verification is important, because when mutations are allowed via `GET` requests, it's easy to perform an attack by sending the link containing mutation to a signed in user.
