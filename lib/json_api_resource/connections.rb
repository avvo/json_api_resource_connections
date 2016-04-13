module JsonApiResource
  module Connections
    autoload :CacheConnection,                        'json_api_resource/connections/cache_connection'
    autoload :CachedCircuitbreakerServerConnection,   'json_api_resource/connections/cached_circuitbreaker_server_connection'
  end
end