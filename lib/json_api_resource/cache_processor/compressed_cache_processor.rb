module JsonApiResource
  module CacheProcessor
    class CompressedCacheProcessor < Base
      
      class_attribute :cache

      class << self

        def write(client, action, *args, result)
          result.each do |item|
            cache.write 

          result.map!(&:id)
          
        end

        def read(client, action, *args)
          set
        end

        private 

        def cache_key(client, action, args)
          # this can come in as a class or as an instance
          #                                       class    |     instance
          class_string = client.is_a?(Class) ? client.to_s : client.class.to_s
          "#{class_string}/#{action}/#{ordered_args(args)}"
        end

        def ordered_args(args)
          args.sort.to_h
        end
      end
    end
  end
end