module JsonApiResource
  module CacheProcessor
    class Base

      class << self 
        def write( client, action, *args, result )
          result
        end

        def read( client, action, *args )
          []
        end
      end
    end
  end
end
