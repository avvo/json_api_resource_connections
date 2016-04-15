module JsonApiResource
  module Connections
    autoload :CacheConnection,                        'json_api_resource/connections/cache_connection'
    autoload :CachedCircuitbreakerServerConnection,   'json_api_resource/connections/cached_circuitbreaker_server_connection'
    autoload :ServerNotReadyError,                    'json_api_resource/connections/server_not_ready_error'
  end
end