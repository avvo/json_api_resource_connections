$LOAD_PATH.unshift File.expand_path('../../lib', __FILE__)

require 'simplecov'
SimpleCov.start
require 'json_api_resource_connecitons'

require 'minitest/autorun'



class User < JsonApiClient::Resource
  self.site = "http://localhost:3000/api/1"

  collection_endpoint :search, request_method: :get
end


class Climb < JsonApiClient::Resource
  self.site = "http://localhost:3000/api/1"

  collection_endpoint :search, request_method: :get
end



class CachedUserResource < JsonApiResource::Resource
  wraps User

  cache_fallback :where, :find


  property :id
  property :name, ""
  property :profession, ""
  property :updated_at, nil
end

class UserResource < JsonApiResource::Resource
  wraps User

  property :id
  property :name, ""
  property :profession, ""
  property :updated_at, nil
end

class ClimbResource < JsonApiResource::Resource
  wraps Climb

  properties  name: "",
              type: "",
             grade: ""
end

class Cache
  
  def initialize
    @store = {}
  end

  def write( key, value )
    @store[key] = value
  end

  def read( key )
    @store[key]
  end
end

JsonApiResource::CacheProcessor::CompressedCacheProcessor.cache = Cache.new
JsonApiResource::Connections::CacheConnection.cache_processor = JsonApiResource::CacheProcessor::CompressedCacheProcessor
JsonApiResource::Connections::CachedCircuitbreakerServerConnection.cache_processor = JsonApiResource::CacheProcessor::CompressedCacheProcessor

def raise_client_error!
  -> (*args){ raise JsonApiClient::Errors::ServerError.new("http://localhost:3000/api/1") }
end