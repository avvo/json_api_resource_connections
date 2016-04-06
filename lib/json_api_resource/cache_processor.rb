module JsonApiResource
  module CacheProcessor
    autoload :Base,                     'json_api_resource/cache_processor/base'
    autoload :CompressedCacheProcessor, 'json_api_resource/cache_processor/compressed_cache_processor'
  end
end