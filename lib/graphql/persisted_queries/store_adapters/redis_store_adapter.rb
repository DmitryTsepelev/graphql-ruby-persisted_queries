# frozen_string_literal: true

require "graphql/persisted_queries/store_adapters/redis_client_builder"

module GraphQL
  module PersistedQueries
    module StoreAdapters
      # Redis adapter for storing persisted queries
      class RedisStoreAdapter < BaseStoreAdapter
        DEFAULT_EXPIRATION = 24 * 60 * 60
        DEFAULT_NAMESPACE = "graphql-persisted-query"

        def initialize(redis_client:, expiration: nil, namespace: nil)
          @redis_proc = build_redis_proc(redis_client)
          @expiration = expiration || DEFAULT_EXPIRATION
          @namespace = namespace || DEFAULT_NAMESPACE
        end

        def fetch_query(hash)
          @redis_proc.call do |redis|
            redis.get(key_for(hash)).tap do |result|
              if result
                trace("fetch_query.cache_hit", adapter: :redis)
              else
                trace("fetch_query.cache_miss", adapter: :redis)
              end
            end
          end
        end

        def save_query(hash, query)
          @redis_proc.call do |redis|
            trace("save_query", adapter: :redis) do
              redis.set(key_for(hash), query, ex: @expiration)
            end
          end
        end

        private

        def key_for(hash)
          "#{@namespace}:#{hash}"
        end

        # rubocop: disable Metrics/MethodLength
        # rubocop: disable Metrics/CyclomaticComplexity
        # rubocop: disable Metrics/PerceivedComplexity
        def build_redis_proc(redis_client)
          if redis_client.is_a?(Hash)
            build_redis_proc(RedisClientBuilder.new(redis_client).build)
          elsif redis_client.is_a?(Proc)
            redis_client
          elsif defined?(::Redis) && redis_client.is_a?(::Redis)
            proc { |&b| b.call(redis_client) }
          elsif defined?(ConnectionPool) && redis_client.is_a?(ConnectionPool)
            proc { |&b| redis_client.with { |r| b.call(r) } }
          else
            raise ArgumentError, ":redis_client accepts Redis, ConnectionPool, Hash or Proc only"
          end
        end
        # rubocop: enable Metrics/MethodLength
        # rubocop: enable Metrics/CyclomaticComplexity
        # rubocop: enable Metrics/PerceivedComplexity
      end
    end
  end
end
