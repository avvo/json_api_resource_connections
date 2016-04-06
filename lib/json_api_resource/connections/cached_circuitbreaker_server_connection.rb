module JsonApiResource
  module Connections
    class CachedCircuitbreakerServerConnection < Multiconnect::Connection::Base
      include Keyable

      class_attribute :cache_processor
      class_attribute :error_notifier

      self.cache_processor = ::JsonApiResource::CacheProcessor::Base

      def initialize(options)
        super options
        @caching            = options.fetch :caching, true
        @timeout            = Time.now
      end

      def report_error( e )
        unless i.is_a? ServerNotReadyError
          error_notifier.notify( self, e ) if error_notifier.present?
        end
      end

      def request( action, *args )
        if ready_for_request?
          
          result = client_request(action, *args)

          cache_processor.write(client, action, args, result) if cache?

          result

        else
          raise ServerNotReadyError
        end

      rescue JsonApiClient::Errors::NotFound => e
        empty_set_with_errors e
      rescue => e
        @timeout = timeout

        # propagate the error up to be handled by Connection::Base
        raise e
      end

      def empty_set_with_errors( e )
        result = JsonApiClient::ResultSet.new

        result.meta = {status: 404}

        result.errors = ActiveModel::Errors.new(result)
        result.errors.add("RecordNotFound", e.message)

        result
      end

      private

      def timeout
        # default circuit broken for 30 seconds. 
        # This should probably be 1 - 2 - 5 - 15 - 30 - 1 min *
        Time.now + 30.seconds
      end

      def ready_for_request?
        Time.now > @timeout
      end

      def cache?
        @caching
      end

      def client_request(action, *args)
        result = self.client.send action, *args

        if result.is_a? JsonApiClient::Scope
          result = result.all
        end

        result
      end
    end
  end
end