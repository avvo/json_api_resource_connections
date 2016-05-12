require 'test_helper'

class CacheConnectionTest < Minitest::Test

  def setup
    @result_block_with_ids = JsonApiClient::ResultSet.new(
                    [User.new({ "id" => 1,
                              "name" => "jon",
                        "profesison" => "photographer",
                        "updated_at" => @timestamp}),
                              
                     User.new({ "id" => 2,
                              "name" => "daniel",
                        "profesison" => "climber",
                        "updated_at" => @timestamp})])

    @proc  = JsonApiResource::CacheProcessor::CompressedCacheProcessor
    @cache = @proc.cache

    @connection = JsonApiResource::Connections::CacheConnection.new client: User
    
    assert_equal @connection.cache_processor, @proc
  end

  def test_can_retrieve_data
    @proc.write( @result_block_with_ids, User, :where, {per_page: 10})

    result = @connection.execute :where, {per_page: 10}

    assert result.success?, $error

    assert_equal @result_block_with_ids, result.data
  end

  def test_notifies_about_error
    result = @connection.execute :where, { not: :in_cache }

    refute result.success?, "should miss cache"

    assert_equal KeyError, $error[:error].class
  end
end