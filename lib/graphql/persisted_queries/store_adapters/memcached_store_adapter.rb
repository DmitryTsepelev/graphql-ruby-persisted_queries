# frozen_string_literal: true

require "graphql/persisted_queries/store_adapters/memcached_client_builder"

module GraphQL
  module PersistedQueries
    module StoreAdapters
      # Redis adapter for storing persisted queries
      class MemcachedStoreAdapter < BaseStoreAdapter
        DEFAULT_EXPIRATION = 24 * 60 * 60
        DEFAULT_NAMESPACE = "graphql-persisted-query"

        def initialize(dalli_client:, expiration: nil, namespace: nil)
          @dalli_proc = build_dalli_proc(dalli_client)
          @expiration = expiration || DEFAULT_EXPIRATION
          @namespace = namespace || DEFAULT_NAMESPACE
        end

        def fetch_query(hash)
          @dalli_proc.call do |dalli|
            dalli.get(key_for(hash)).tap do |result|
              if result
                trace("fetch_query.cache_hit", adapter: :memcached)
              else
                trace("fetch_query.cache_miss", adapter: :memcached)
              end
            end
          end
        end

        def save_query(hash, query)
          @dalli_proc.call do |dalli|
            trace("save_query", adapter: :memcached) do
              dalli.set(key_for(hash), query, @expiration)
            end
          end
        end

        private

        def key_for(hash)
          "#{@namespace}:#{hash}"
        end

        def build_dalli_proc(dalli_client)
          if dalli_client.is_a?(Hash)
            build_dalli_proc(MemcachedClientBuilder.new(dalli_client).build)
          elsif dalli_client.is_a?(Proc)
            dalli_client
          elsif defined?(::Dalli::Client) && dalli_client.is_a?(::Dalli::Client)
            proc { |&b| b.call(dalli_client) }
          else
            raise ArgumentError, ":dalli_client accepts Dalli::Client, Hash or Proc only"
          end
        end
      end
    end
  end
end
