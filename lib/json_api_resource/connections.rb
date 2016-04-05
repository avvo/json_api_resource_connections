module JsonApiResource
  module Connections
    autoload :CacheConnection,                        'json_api_resource/connections/cache_connection'
    autoload :CachedCircuitbreakerServerConnection,   'json_api_resource/connections/cache_connection'
    autoload :Keyable,                                'json_api_resource/connections/keyable'
  end
end