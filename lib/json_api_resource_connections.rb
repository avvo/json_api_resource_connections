require 'active_support'
require 'active_support/callbacks'
require 'active_support/concern'
require 'active_support/core_ext/module'
require 'active_support/core_ext/class/attribute'
require 'active_support/core_ext/object/deep_dup'
require 'json_api_resource'
require "json_api_resource_connections/version"

require 'multiconnect'

require 'json_api_resource/cache_processor'

require 'json_api_resource/connections/cache_connection'
require 'json_api_resource/connections/cached_circuitbreaker_server_connection'
require 'json_api_resource/connections/server_not_ready_error'


module JsonApiResourceConnections

  extend ActiveSupport::Concern

  included do

    include Multiconnect::Connectable

    class << self
      class_attribute :_fallbacks
      self._fallbacks = []

      class_attribute :_cache_first
      self._cache_first = []

      def cache_fallback(*actions)
        self._fallbacks = _fallbacks + Array(actions)
        options = { client: self.client_class }
        options[:only] = self._fallbacks if self._fallbacks.present?

        add_connection JsonApiResource::Connections::CacheConnection, options
      end

      def try_cache_first(*actions)
        self._cache_first = _cache_first + Array(actions)
        options = { client: self.client_class }
        options[:only] = self._cache_first if self._cache_first.present?

        prepend_connection JsonApiResource::Connections::CacheConnection, options
      end

      def wraps(client)
        self.client_class = client

        # now that we know where to connect to, let's do it
        add_connection JsonApiResource::Connections::CachedCircuitbreakerServerConnection, client: self.client_class
      end

      def cacheless_find( id )
        result = direct_execute :find, id
        JsonApiResource::Handlers::FindHandler.new(result).result
      end

      def cacheless_where( opts = {} )
        direct_execute :where, opts
      end

      private

      # skips looking in cache first and goes to the server directly
      def direct_execute( action, *args )
        cacheless_connection.execute(action, *args)
      end

      def cacheless_connection
        @cacheless_connection ||=_connections.find do |c| 
          c.is_a? JsonApiResource::Connections::CachedCircuitbreakerServerConnection
        end
      end
    end
  end
end

JsonApiResource::Resource.send :include, JsonApiResourceConnections