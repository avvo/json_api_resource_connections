require 'active_support'
require 'active_support/callbacks'
require 'active_support/concern'
require 'active_support/core_ext/module'
require 'active_support/core_ext/class/attribute'
require 'json_api_resource'
require "json_api_resource_connecitons/version"

module JsonApiResourceConnections
  require 'json_api_resource/connections'
  require 'json_api_resource/cache_processor'

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