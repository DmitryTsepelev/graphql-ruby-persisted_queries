# Tracing

Tracing is an experimental feature that, when enabled, uses the tracing system defined in `graphql-ruby` to surface these events:

* `persisted_queries.fetch_query.cache_hit` - Triggered when a store adapter successfully looks up a hash and finds a query.
* `persisted_queries.fetch_query.cache_miss` - Triggered when a store adapter attempts to look up a hash but cannot find it.
* `persisted_queries.save_query` - Triggered when a store adapter persists a query.

All events include a metadata hash as their `data` parameter.  This hash currently only includes the name of the adapter that triggered the event.

## Usage

Tracing must be opted into via the plugin configuration for the events to trigger.  Once they are enabled, any tracer that is defined on the schema will get the following events yielded to them.  An example configuration will look similar to this:

```ruby
class GraphqlSchema < GraphQL::Schema
  use GraphQL::PersistedQueries, tracing: true
  tracer MyPersistedQueriesTracer
end
```

Tracers in this plugin integrate with the `GraphQL::Tracing` feature in [`graphql-ruby`](https://github.com/rmosolgo/graphql-ruby).  The same tracers are used for tracing events directly from `graphql-ruby` and this plugin.  The [guide on "Tracing"](https://graphql-ruby.org/queries/tracing.html) in `graphql-ruby` has implementation details, but an example tracer would look similar to this:

```ruby
class MyPersistedQueriesTracer
  def self.trace(key, data)
    yield.tap do |result|
      # Note: this tracer will get called for these persisted queries events as
      # well as all events traced by the graphql-ruby gem.
      case key
      when "persisted_queries.fetch_query.cache_hit"
        # data = { adapter: :redis }
        # result = query string that got hit
        # increment a counter metric to track cache hits
      when "persisted_queries.fetch_query.cache_miss"
        # data = { adapter: :redis }
        # result = nil
        # increment a counter metric to track cache misses
      when "persisted_queries.save_query"
        # data = { adapter: :redis }
        # result = return value from method call
        # increment a counter metric to track saved queries
      end
    end
  end
end
```

## Be aware of tracers-as-notifications

A word of caution about the `cache_hit` and `cache_miss` events: they yield an empty block.  The `GraphQL::Tracing` feature typically wraps around the code performing the event.  The `save_query` event works this way, too -- the block that is yielded is essentially the `StoreAdapter#save` method.  This means you can add timing instrumentation for this call.  However, the `cache_hit` and `cache_miss` events are simply event notifications and do not wrap any code.  This means that they won't yield anything meaningful and they can't be timed.
