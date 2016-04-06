module JsonApiResource
  module Connections
    class CacheConnection < Multiconnect::Connection::Base
      include Keyable

      class_attribute :cache_processor
            
      self.cache_processor = ::JsonApiResource::CacheProcessor::Base
      
      class << self
        attr_accessor :cache
      end

      def report_error( e )
      end

      def request( action, *args )
        cache_processor.read client, action, args
      end
    end
  end
end