require 'test_helper'

class ServerNotReadyErrorTest < Minitest::Test

  def test_message_adds_previous_error
    error = JsonApiResource::Connections::ServerNotReadyError.new('some message')
    assert_equal '', error.message
  end
end