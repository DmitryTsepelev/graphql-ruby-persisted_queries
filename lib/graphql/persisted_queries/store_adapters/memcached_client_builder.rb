# frozen_string_literal: true

module GraphQL
  module PersistedQueries
    module StoreAdapters
      # Builds Redis object instance based on passed hash
      class MemcachedClientBuilder
        def initialize(memcached_url: nil, memcached_host: nil, memcached_port: nil, **dalli_args)
          require "dalli"

          @memcached_url = memcached_url
          @memcached_host = memcached_host
          @memcached_port = memcached_port
          @dalli_args = dalli_args
        rescue LoadError => e
          msg = "Could not load the 'dalli' gem, please add it to your gemfile or " \
                "configure a different adapter, e.g. use GraphQL::PersistedQueries, store: :memory"
          raise e.class, msg, e.backtrace
        end

        def build
          if @memcached_url && (@memcached_host || @memcached_port)
            raise ArgumentError, "memcached_url cannot be passed along with memcached_host or " \
                                 "memcached_port options"
          end

          ::Dalli::Client.new(@memcached_url || build_memcached_url, **@dalli_args)
        end

        private

        def build_memcached_url
          "#{@memcached_host}:#{@memcached_port}"
        end
      end
    end
  end
end
