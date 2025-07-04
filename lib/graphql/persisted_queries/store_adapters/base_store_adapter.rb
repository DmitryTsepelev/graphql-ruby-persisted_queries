# frozen_string_literal: true

module GraphQL
  module PersistedQueries
    module StoreAdapters
      # Base class for all store adapters
      class BaseStoreAdapter
        include GraphQL::Tracing::Traceable
        attr_writer :tracers

        def initialize(**_options)
          @name = :base
        end

        def fetch_query(hash, options = {})
          compiled_query = options[:compiled_query] || false
          key = build_key(hash, compiled_query)

          fetch(key).tap do |result|
            if result
              trace("fetch_query.cache_hit", adapter: @name) { result }
            else
              trace("fetch_query.cache_miss", adapter: @name)
            end
          end
        end

        def save_query(hash, query, compiled_query: false)
          key = build_key(hash, compiled_query)
          trace("save_query", adapter: @name) do
            query.tap { save(key, query) }
          end
        end

        def fetch(_hash)
          raise NotImplementedError
        end

        def save(_hash, _query)
          raise NotImplementedError
        end

        def trace(key, metadata)
          if @tracers
            key = "persisted_queries.#{key}"
            block_given? ? super : super {}
          elsif block_given?
            yield
          end
        end

        def serialize(query)
          Marshal.dump(query)
        end

        def deserialize(serialized_query)
          Marshal.load(serialized_query) if serialized_query # rubocop:disable Security/MarshalLoad
        end

        private

        def build_key(hash, compiled_query)
          key = "#{RUBY_ENGINE}-#{RUBY_VERSION}:#{GraphQL::VERSION}:#{hash}"
          compiled_query ? "compiled:#{key}" : key
        end
      end
    end
  end
end
