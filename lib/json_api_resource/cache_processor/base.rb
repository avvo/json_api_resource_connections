module JsonApiResource
  module CacheProcessor
    class Base

      class << self 
        def write( result, client, action, *args )
          result
        end

        def read( client, action, *args )
          []
        end
      end
    end
  end
end
