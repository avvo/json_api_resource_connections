require "json_api_resource_connecitons/version"

module JsonApiResourceConnections
  require 'json_api_resource/connecitons'
  require 'json_api_resource/cache_processor'

  extend ActiveSupport::Concern

  included do

    include Multiconnect::Connectable

    class << self
      class_attribute :_fallbacks
      self._fallbacks = []

      def cache_fallback(actions)
        self._fallbacks = _fallbacks + Array(actions)
        add_connection Connections::CacheConnection client: self.client_class, only: self._fallbacks
      end

      def wraps(client)
        self.client_class = client

        # now that we know where to connect to, let's do it
        add_connection Connections::CachedCircuitbreakerServerConnection, client: self.client_class
      end
    end

    def connection
      @connection ||= Connections::CachedCircuitbreakerServerConnection.new client: client, cache: false
    end
  end
end

JsonApiResource::Resource.instance_eval do
  include JsonApiResourceConnections
end