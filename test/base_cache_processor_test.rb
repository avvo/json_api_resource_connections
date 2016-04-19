require 'test_helper'

class BaseCacheProcessorTest < Minitest::Test

  def test_responds_to_write
    assert JsonApiResource::CacheProcessor::Base.write(User, :find, 1, JsonApiClient::ResultSet.new())
    assert JsonApiResource::CacheProcessor::Base.write(User, :where, {id: 1, per_page: 10}, JsonApiClient::ResultSet.new())
  end

  def test_responds_to_read
    assert JsonApiResource::CacheProcessor::Base.fetch(User, :find, 1)
    assert JsonApiResource::CacheProcessor::Base.fetch(User, :where, {id: 1, per_page: 10})
  end

end