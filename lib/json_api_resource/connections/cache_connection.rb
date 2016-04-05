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
        key = cache_key(client, action, args)
        set = self.class.cache.fetch key
        self.cache_processor.extract set
      end
    end
  end
end