module Fog
  module Storage
    class Alilyun
      class Real
        # Copy object
        #
        # ==== Parameters
        # * source_container_name<~String> - Name of source bucket
        # * source_object_name<~String> - Name of source object
        # * target_container_name<~String> - Name of bucket to create copy in
        # * target_object_name<~String> - Name for new copy of object
        # * options<~Hash> - Additional headers options={}
        def copy_object(source_bucket, source_object, target_bucket, target_object)
          #headers = { 'X-Copy-From' => "/#{source_container_name}/#{source_object_name}" }.merge(options)
          headers = { 'x-oss-copy-source' => "/#{source_bucket}/#{source_object}" }
          location = get_bucket_location(target_bucket)
          endpoint = "http://"+location+".aliyuncs.com"
          resource = target_bucket+'/'+target_object
          request({
            :expects  => [200, 203],
            :headers  => headers,
            :method   => 'PUT',
            :path     => target_object,
            :bucket   => target_bucket,
            :resource => resource,
            :endpoint => endpoint
          })
        end
      end
      
      class Mock
        def copy_object(source_bucket, source_object, target_bucket, target_object)
          
        end
      end
    end
  end
end
