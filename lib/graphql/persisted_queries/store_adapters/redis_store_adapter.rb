# frozen_string_literal: true

require "graphql/persisted_queries/store_adapters/redis_client_builder"

module GraphQL
  module PersistedQueries
    module StoreAdapters
      # Redis adapter for storing persisted queries
      class RedisStoreAdapter < BaseStoreAdapter
        DEFAULT_EXPIRATION = 24 * 60 * 60
        DEFAULT_NAMESPACE = "graphql-persisted-query"

        def initialize(redis_client: {}, expiration: nil, namespace: nil)
          @redis_proc = build_redis_proc(redis_client)
          @expiration = expiration || DEFAULT_EXPIRATION
          @namespace = namespace || DEFAULT_NAMESPACE
          @name = :redis
        end

        def fetch(hash)
          @redis_proc.call do |redis|
            deserialize(redis.get(key_for(hash)))
          end
        end

        def save(hash, query)
          @redis_proc.call { |redis| redis.set(key_for(hash), serialize(query), ex: @expiration) }
        end

        private

        def key_for(hash)
          "#{@namespace}:#{hash}"
        end

        # rubocop: disable Metrics/MethodLength
        def build_redis_proc(redis_client)
          if redis_client.is_a?(Hash)
            build_redis_proc(RedisClientBuilder.new(**redis_client).build)
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
      end
    end
  end
end
