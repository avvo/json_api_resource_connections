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
      result = CachedUserResource.search

      assert_equal 500, result.meta[:status]
      assert_empty result
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

  def test_resource_instance_connection_is_overriden
    @resource = ClimbResource.new
    
    @resource.client.stub :save, raise_client_error! do
      
      result = @resource.save

      refute result
    end

    result = @resource.save

    refute result, "circuit should still be broken"

    @resource.client.stub :save, true do 
      @resource.connection.stub :ready_for_request?, true do
        
        result = @resource.save
        assert result, "circuit should be restored"
      end
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
