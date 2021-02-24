# Change log

## master

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
