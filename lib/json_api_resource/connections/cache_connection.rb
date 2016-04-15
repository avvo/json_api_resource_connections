module JsonApiResource
  module Connections
    class CacheConnection < Multiconnect::Connection::Base

      class_attribute :cache_processor
      class_attribute :error_notifier
            
      self.cache_processor = ::JsonApiResource::CacheProcessor::Base
      
      class << self
        attr_accessor :cache
      end

      def report_error( e )
        error_notifier.notify( self, e ) if error_notifier.present?
      end

      def request( action, *args )
        cache_processor.read client, action, *args
      end
    end
  end
end