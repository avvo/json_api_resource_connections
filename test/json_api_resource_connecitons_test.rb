require 'test_helper'

class JsonApiResourceConnectionsTest < Minitest::Test
  def test_that_it_has_a_version_number
    refute_nil ::JsonApiResourceConnections::VERSION
  end

  def test_connections_load
    assert_equal 1, UserResource._connections.count
    assert_equal 2, CachedUserResource._connections.count
  end

  def test_connections_initialize_properly
    assert_equal JsonApiResource::CacheProcessor::CompressedCacheProcessor.cache.class, Cache
    assert_equal JsonApiResource::Connections::CacheConnection.cache_processor, JsonApiResource::CacheProcessor::CompressedCacheProcessor
    assert_equal JsonApiResource::Connections::CachedCircuitbreakerServerConnection.cache_processor, JsonApiResource::CacheProcessor::CompressedCacheProcessor
  end

  def test_cache_connection_provides_fallback_for_successful_call
    User.stub :search, raise_client_error! do
      assert_raises JsonApiResource::Errors::UnsuccessfulRequest do
        result = CachedUserResource.search

      end
    end

    CachedUserResource._connections.first.stub :ready_for_request?, true do
      User.stub :search, JsonApiClient::ResultSet.new([User.new(id: 10), User.new(id: 15)]) do
        result = CachedUserResource.search

        refute_empty result
      end
    end


    User.stub :search, raise_client_error! do
      result = CachedUserResource.search

      refute_empty result
    end
  end

  def test_cache_first_avoids_call_on_cache_hit
    CachedClimbResource._connections[1].stub :ready_for_request?, true do
      Climb.stub :search, JsonApiClient::ResultSet.new([Climb.new(id: 10), Climb.new(id: 15)]) do
        result = CachedClimbResource.search

        refute_empty result
      end
    end
    
    Climb.stub :search, raise_client_error! do
      result = CachedClimbResource.search

      refute_empty result
    end
  end
end
