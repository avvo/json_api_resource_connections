module JsonApiResource
  module CacheProcessor
    class Base

      class << self 
        def process(action, *args, result)
          result
        end

        def extract(set)
          set
        end
      end
    end
  end
end
