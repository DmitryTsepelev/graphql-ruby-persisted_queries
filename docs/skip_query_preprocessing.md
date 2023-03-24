# Skipping some preprocessing steps

It does not make much sense to revalidate persisted query—we did it earlier, so it can be disabled in the `#execute` call:

```ruby
GraphqlSchema.execute(
  params[:query],
  variables: ensure_hash(params[:variables]),
  context: {
    extensions: ensure_hash(params[:extensions])
  },
  operation_name: params[:operationName],
  validate: params[:query].present?
)
```

Moreover, some analyzers can be disabled as well: in order to do that just pass the same check `params[:query].present?` to the context and then add early exit to your analyzers based on this flag.
