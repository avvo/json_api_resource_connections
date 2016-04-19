require 'test_helper'

class CircuitbreakerConnectionTest < Minitest::Test

  def setup
    @connection = JsonApiResource::Connections::CachedCircuitbreakerServerConnection.new client: User, caching: false
  end

  def test_can_connect_to_server
    User.stub :where, JsonApiClient::Scope.new(id: 6) do
      User.where.stub :all, JsonApiClient::ResultSet.new([User.new()]) do

        result = @connection.execute(:where, 6)

        assert result.success?
      
        refute_empty result.data
        assert_equal 1, result.count
        assert_equal User, result.first.class
      end
    end
  end

  def test_failed_connection_breaks_the_cirtcuit
    User.stub :where, JsonApiClient::Scope.new(id: 6) do
      User.where.stub :all, raise_client_error! do

        result = @connection.execute(:where, 6)

        assert result

        refute result.success?
      end
    end
  end

  def test_failed_connection_resumes_after_timeout
    User.stub :where, JsonApiClient::Scope.new(id: 6) do
      User.where.stub :all, raise_client_error! do

        result = @connection.execute(:where, 6)

        assert result

        refute result.success?
      end

      result = @connection.execute(:where, 6)

      assert result

      refute result.success?, "circuit should still be broken"

      @connection.stub :ready_for_request?, true do
        User.where.stub :all, JsonApiClient::ResultSet.new([User.new()]) do
          result = @connection.execute(:where, 6)

          assert result.success?, "circuit should be restored"
          
          refute_empty result.data
          assert_equal 1, result.count
          assert_equal User, result.first.class
        end
      end
    end
  end

  def test_failed_connection_reports_errors
    count = $error[:count]
    User.stub :where, JsonApiClient::Scope.new(id: 6) do
      User.where.stub :all, raise_client_error! do

        result = @connection.execute(:where, 6)

        assert_equal count + 1, $error[:count], "error count should have gone up"
      end
    end
  end

  def test_broken_connection_does_not_report
    count = $error[:count]
    User.stub :where, JsonApiClient::Scope.new(id: 6) do
      User.where.stub :all, raise_client_error! do

        result = @connection.execute(:where, 6)

        assert_equal count + 1, $error[:count], "error count should have gone up"

        15.times do
          @connection.execute(:where, 6)
        end

        assert_equal count + 1, $error[:count], "circuit broken connection should not report errors"

        @connection.stub :ready_for_request?, true do
          result = @connection.execute(:where, 6)

          refute result.success?

          assert_equal count + 2, $error[:count]
        end
      end
    end
  end

  def test_404_returns_set
    User.stub :where, JsonApiClient::Scope.new(id: 6) do
      User.where.stub :all, raise_404! do

        result = @connection.execute(:where, 6)

        assert result.success?
      
        assert_empty result.data
        assert_equal 404, result.meta[:status]
      end
    end
  end

  def test_connection_can_cache
    connection = JsonApiResource::Connections::CachedCircuitbreakerServerConnection.new client: User

    assert connection.cache_processor
    assert_equal JsonApiResource::CacheProcessor::CompressedCacheProcessor, connection.cache_processor

    User.stub :where, JsonApiClient::Scope.new(id: [10, 15], order: :id) do
      User.where.stub :all, JsonApiClient::ResultSet.new([User.new(id: 10), User.new(id: 15)]) do
        result = connection.execute(:where, id: [10, 15], order: :id)

        assert result.success?

        assert connection.cache_processor.fetch User, :where, {:id=>[10, 15], :order=>:id}
      end
    end

  end

  def test_connection_does_not_cache_on_error
    connection = JsonApiResource::Connections::CachedCircuitbreakerServerConnection.new client: User

    assert connection.cache_processor
    assert_equal JsonApiResource::CacheProcessor::CompressedCacheProcessor, connection.cache_processor

    User.stub :where, JsonApiClient::Scope.new(id: [10, 19]) do
      User.where.stub :all, raise_client_error! do
        result = connection.execute(:where, id: [10, 19])

        refute result.success?



        assert_raises KeyError do
          connection.cache_processor.fetch User, :where, id: [10, 19]
        end
      end
    end
  end
end