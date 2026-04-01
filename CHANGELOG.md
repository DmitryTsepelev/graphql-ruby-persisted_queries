# Change log

## 2.0.0 (2025-06-28)

- [PR#87](https://github.com/DmitryTsepelev/graphql-ruby-persisted_queries/pull/87)
[[BREAKING](https://github.com/DmitryTsepelev/graphql-ruby-persisted_queries/pull/87#issuecomment-3008620281)] Add option to skip query marshalling for in-memory storage ([@viralpraxis][])

## 1.8.2 (2025-06-12)

- [PR#79](https://github.com/DmitryTsepelev/graphql-ruby-persisted_queries/pull/79)
Deprecate old ruby and gql versions ([@DmitryTsepelev][])
- [PR#78](https://github.com/DmitryTsepelev/graphql-ruby-persisted_queries/pull/78)
Migrate CompiledQueries instrumentation to tracer ([@DmitryTsepelev][])

## 1.8.1 (2024-06-01)

- [PR#77](https://github.com/DmitryTsepelev/graphql-ruby-persisted_queries/pull/77)
Fix serialization of Document (broken by [this change](https://github.com/rmosolgo/graphql-ruby/commit/7de7a1f98d4299abc1fb7deb5ca0ed2190867ab6)) ([@DmitryTsepelev][])

## 1.8.0 (2024-03-31)

- [PR#73](https://github.com/DmitryTsepelev/graphql-ruby-persisted_queries/pull/73)
Use trace_with instead of instrument for modern versions of graphql ([@DmitryTsepelev][])

- [PR#64](https://github.com/DmitryTsepelev/graphql-ruby-persisted_queries/pull/64)
Add query to cache_hit trace event ([@DmitryTsepelev][])

## 1.7.0 (2023-02-02)

- [PR#62](https://github.com/DmitryTsepelev/graphql-ruby-persisted_queries/pull/62)
Fix double hashing of keys in case of redis_with_local_cache_store adapter ([@mpospelov][])
- [PR#62](https://github.com/DmitryTsepelev/graphql-ruby-persisted_queries/pull/62) Drop tracers= implementation as it's no longer valid ([@mpospelov][])

## 1.6.1 (2022-11-17)

- [PR#60](https://github.com/DmitryTsepelev/graphql-ruby-persisted_queries/pull/60)
Handle situations when prepare_ast happens before instrumentation ([@DmitryTsepelev][])

## 1.6.0 (2022-10-10)

- [PR#57](https://github.com/DmitryTsepelev/graphql-ruby-persisted_queries/pull/57) Refactor code to use instrumentation instead of a monkey patch, deprecate graphql-ruby 1.10 and 1.11 ([@DmitryTsepelev][])

## 1.5.1 (2022-09-28)

- [PR#56](https://github.com/DmitryTsepelev/graphql-ruby-persisted_queries/pull/56) Support graphql-ruby 2.0.14 ([@DmitryTsepelev][])

## 1.5.0 (2022-02-10)

- [PR#53](https://github.com/DmitryTsepelev/graphql-ruby-persisted_queries/pull/53) Support graphql-ruby 2.0.0 ([@DmitryTsepelev][])

## 1.4.0 (2022-01-28)

- [PR#52](https://github.com/DmitryTsepelev/graphql-ruby-persisted_queries/pull/52) Drop Ruby 2.5 support, add Ruby 3.0 ([@DmitryTsepelev][])

## 1.3.0 (2021-10-19)

- [PR#51](https://github.com/DmitryTsepelev/graphql-ruby-persisted_queries/pull/51) Drop Ruby 2.3 and 2.4 support ([@DmitryTsepelev][])

## 1.2.4 (2021-06-07)

- [PR#50](https://github.com/DmitryTsepelev/graphql-ruby-persisted_queries/pull/50) Support empty redis_client arg on redis with locale cache ([@louim][])

## 1.2.3 (2021-05-14)

- [PR#49](https://github.com/DmitryTsepelev/graphql-ruby-persisted_queries/pull/49) Allow nil redis_client with ENV["REDIS_URL"] ([@louim][])

## 1.2.2 (2021-04-21)

- [PR#47](https://github.com/DmitryTsepelev/graphql-ruby-persisted_queries/pull/47) Properly initialize memory adapter inside RedisWithLocalCacheStoreAdapter ([@DmitryTsepelev][])

## 1.2.1 (2021-03-07)

- [PR#43](https://github.com/DmitryTsepelev/graphql-ruby-persisted_queries/pull/43) Properly handle configuration when schema is inherited ([@DmitryTsepelev][])
- [PR#44](https://github.com/DmitryTsepelev/graphql-ruby-persisted_queries/pull/44) Deprecate graphql-ruby 1.8 and 1.9  ([@DmitryTsepelev][])

## 1.2.0 (2021-02-24)

- [PR#39](https://github.com/DmitryTsepelev/graphql-ruby-persisted_queries/pull/39) Implement compiled queries  ([@DmitryTsepelev][])

## 1.1.1 (2020-12-03)

- [PR#37](https://github.com/DmitryTsepelev/graphql-ruby-persisted_queries/pull/37) Fix deprecation warnings ([@rbviz][])

## 1.1.0 (2020-11-16)

- [PR#36](https://github.com/DmitryTsepelev/graphql-ruby-persisted_queries/pull/36) Support Ruby 2.7.0 ([@DmitryTsepelev][])

## 1.0.2 (2020-06-29)

- [PR#35](https://github.com/DmitryTsepelev/graphql-ruby-persisted_queries/pull/35) fix args for GraphQL::Query::Result ([@ogidow][])

## 1.0.1 (2020-06-25)

- [PR#34](https://github.com/DmitryTsepelev/graphql-ruby-persisted_queries/pull/34) Return GraphQL::Query::Result when raise error ([@ogidow][])

## 🥳 1.0.0 (2020-03-31)

- [PR#30](https://github.com/DmitryTsepelev/graphql-ruby-persisted_queries/pull/30) **BREAKING CHANGE** Move extenstions to the query context ([@DmitryTsepelev][])

## 0.5.1 (2020-03-18)

- [PR#33](https://github.com/DmitryTsepelev/graphql-ruby-persisted_queries/pull/33) Support AST analyzers ([@DmitryTsepelev][])

## 0.5.0 (2020-03-12)

- [PR#29](https://github.com/DmitryTsepelev/graphql-ruby-persisted_queries/pull/29) Instrumentation via graphql-ruby's tracer feature ([@bmorton][])

## 0.4.0 (2020-02-26)

- [PR#26](https://github.com/DmitryTsepelev/graphql-ruby-persisted_queries/pull/26) Add Memcached store ([@JanStevens][])

## 0.3.0 (2020-02-21)

- [PR#24](https://github.com/DmitryTsepelev/graphql-ruby-persisted_queries/pull/24) Add multiplex support ([@DmitryTsepelev][])
- [PR#23](https://github.com/DmitryTsepelev/graphql-ruby-persisted_queries/pull/23) Adapter for Redis-backed in-memory store ([@bmorton][])
- [PR#22](https://github.com/DmitryTsepelev/graphql-ruby-persisted_queries/pull/22) Add `verify_http_method` option restricting mutations to be performed via `GET` requests ([@DmitryTsepelev][])

## 0.2.0 (2020-02-11)

- [PR#17](https://github.com/DmitryTsepelev/graphql-ruby-persisted_queries/pull/17) Allow an optional custom error handler so that implementors can control failure scenarios when query resolution fails ([@bmorton][])

## 0.1.3 (2020-01-30)

- [PR#15](https://github.com/DmitryTsepelev/graphql-ruby-persisted_queries/pull/15) Allow optional custom expiration and namespace for Redis store ([@bmorton][])

## 0.1.2 (2020-01-29)

- [PR#13](https://github.com/DmitryTsepelev/graphql-ruby-persisted_queries/pull/13) Support `graphql-ruby` 1.10 ([@DmitryTsepelev][])

## 0.1.1 (2019-10-24)

- [PR#7](https://github.com/DmitryTsepelev/graphql-ruby-persisted_queries/pull/7) Improved Redis configuration – added `Proc` and `ConnectionPool` support ([@DmitryTsepelev][])

## 0.1.0 (2019-10-21)

- Initial version ([@DmitryTsepelev][])

[@DmitryTsepelev]: https://github.com/DmitryTsepelev
[@bmorton]: https://github.com/bmorton
[@JanStevens]: https://github.com/JanStevens
[@ogidow]: https://github.com/ogidow
[@rbviz]: https://github.com/rbviz
[@louim]: https://github.com/louim
[@mpospelov]: https://github.com/mpospelov
[@viralpraxis]: https://github.com/viralpraxis
