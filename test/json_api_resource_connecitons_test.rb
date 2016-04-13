require 'test_helper'

class JsonApiResourceConnecitonsTest < Minitest::Test
  def test_that_it_has_a_version_number
    refute_nil ::JsonApiResourceConnecitons::VERSION
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
end
