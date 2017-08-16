module JsonApiResource
  module Connections
    class ServerNotReadyError < StandardError

      DEFAULT_PREVIOUS_MESSAGE = 'No message passed'

      def initialize(previous_error = DEFAULT_PREVIOUS_MESSAGE)
        @previous_error = previous_error
      end

      def to_s
        "#{super}  *** Previous Error:: [#{ @previous_error }]"
      end

    end
  end
end