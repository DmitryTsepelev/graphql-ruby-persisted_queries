# Error handling

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
