# frozen_string_literal: true

module GraphQL
  module PersistedQueries
    module StoreAdapters
      # Redis adapter for storing persisted queries
      class RedisStoreAdapter < BaseStoreAdapter
        attr_reader :storage

        def initialize(client: nil, **options)
          require "redis"

          if client && options.any?
            raise ArgumentError, "client cannot be passed along with redis_url, redis_host" \
                                 ", redis_port or redis_db_name options"
          end

          @storage = client || configure_redis_client(options)
        rescue LoadError => e
          msg = "Could not load the 'redis' gem, please add it to your gemfile or " \
                "configure a different adapter, e.g. use GraphQL::PersistedQueries, store: :memory"
          raise e.class, msg, e.backtrace
        end

        def fetch_query(hash)
          storage.get(key_for(hash))
        end

        def save_query(hash, query)
          storage.set(key_for(hash), query)
        end

        private

        def key_for(hash)
          "persisted-query-#{hash}"
        end

        # rubocop:disable Metrics/LineLength
        def configure_redis_client(redis_url: nil, redis_host: nil, redis_port: nil, redis_db_name: nil)
          if redis_url && (redis_host || redis_port || redis_db_name)
            raise ArgumentError, "redis_url cannot be passed along with redis_host, redis_port " \
                                 "or redis_db_name options"
          end

          redis_url ||= build_redis_url(
            redis_host: redis_host,
            redis_port: redis_port,
            redis_db_name: redis_db_name
          )

          Redis.new(url: redis_url)
        end
        # rubocop:enable Metrics/LineLength

        DEFAULT_REDIS_DB = "0"

        def build_redis_url(redis_host: nil, redis_port: nil, redis_db_name: nil)
          redis_db_name ||= DEFAULT_REDIS_DB
          redis_base_url = ENV["REDIS_URL"] || "redis://#{redis_host}:#{redis_port}"
          URI.join(redis_base_url, redis_db_name).to_s
        end
      end
    end
  end
end
