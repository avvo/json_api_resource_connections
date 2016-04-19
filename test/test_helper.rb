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

  cache_fallback :where, :find, :search


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

  def fetch( key )
    @store.fetch key
  end
end

$error = {conn: nil, error: nil, count: 0}

class Notifier < JsonApiResource::ErrorNotifier::Base
  class_attribute :count
  self.count = 0

  class << self
    def notify( connection, error )
      self.count += 1
      $error = {conn: connection.class, error: error, count: count}
    end
  end 
end

JsonApiResource::CacheProcessor::CompressedCacheProcessor.cache = Cache.new
JsonApiResource::Connections::CacheConnection.cache_processor = JsonApiResource::CacheProcessor::CompressedCacheProcessor
JsonApiResource::Connections::CachedCircuitbreakerServerConnection.cache_processor = JsonApiResource::CacheProcessor::CompressedCacheProcessor

JsonApiResource::Connections::CacheConnection.error_notifier = Notifier
JsonApiResource::Connections::CachedCircuitbreakerServerConnection.error_notifier = Notifier

def raise_client_error!
  -> (*args){ raise JsonApiClient::Errors::ServerError.new("http://localhost:3000/api/1") }
end

def raise_404!
  -> (*args){ raise JsonApiClient::Errors::NotFound.new("http://localhost:3000/api/1") }
end