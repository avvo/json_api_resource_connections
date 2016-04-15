module JsonApiResource
  module CacheProcessor
    class CompressedCacheProcessor < Base
      
      class_attribute :cache

      class << self

        def write(result, client, action, *args)
          result_set = Array(result)

          key = cache_key(client, action, *args)
          
          # result set has ids and we can break the set down into an array of ids and the objects
          if splitable?(result_set)
            
            write_ids(key, result_set)
            
            write_objects(client, action, result_set)

          else
            cache.write key, result_set
          end

          result
        end

        def read(client, action, *args)
          key = cache_key(client, action, *args)
          set = cache.read key

          # set can be an array of blobs or an array of ids
          set.map do |item|
            # if the results are ids
            if item.is_a? Integer
              # grab the actual object from cache
              key = item_cache_key(client, action, item)
              cache.read key
            # if they are not ids
            else
              # they have to be the full objects. return them
              item
            end
          end
        end

        private 

        def cache_key(client, action, *args)
          # this can come in as a class or as an instance
          #                                       class    |     instance
          class_string = client.is_a?(Class) ? client.to_s : client.class.to_s
          class_string = class_string.underscore
          args = args.present? ? ordered_args(*args) : nil
          "#{class_string}/#{action}/#{args}"
        end

        def item_cache_key(client, action, id)
          "#{cache_key(client, action)}id:#{id}"
        end

        def ordered_args(*args)
          args.map do |arg|
            arg.is_a?(Hash) ? arg.sort.to_h : arg
          end.sort
        end

        def splitable?(result_set)
          result_set.select{|_| _["id"]}.present?
        end

        def write_ids(key, result_set)
          cache.write key, result_set.map{|_| _["id"]}
        end

        def write_objects(client, action, result_set)
          result_set.each do |item|
            key = item_cache_key client, action, item["id"]
            cache.write key, item
          end
        end
      end
    end
  end
end