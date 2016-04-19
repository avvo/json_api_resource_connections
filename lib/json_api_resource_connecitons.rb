require 'active_support'
require 'active_support/callbacks'
require 'active_support/concern'
require 'active_support/core_ext/module'
require 'active_support/core_ext/class/attribute'
require 'active_support/core_ext/object/deep_dup'
require 'json_api_resource'
require "json_api_resource_connecitons/version"

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

      def cache_fallback(*actions)
        self._fallbacks = _fallbacks + Array(actions)
        add_connection JsonApiResource::Connections::CacheConnection, client: self.client_class, only: self._fallbacks
      end

      def wraps(client)
        self.client_class = client

        # now that we know where to connect to, let's do it
        add_connection JsonApiResource::Connections::CachedCircuitbreakerServerConnection, client: self.client_class
      end
    end

    def connection
      @connection ||= JsonApiResource::Connections::CachedCircuitbreakerServerConnection.new( client: self.client, caching: false )
    end
  end
end

JsonApiResource::Resource.send :include, JsonApiResourceConnections