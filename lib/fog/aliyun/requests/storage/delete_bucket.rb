module Fog
  module Storage
    class Alilyun
      class Real
        # Delete an existing bucket
        #
        # ==== Parameters
        # * container<~String> - Name of container to delete
        # * object<~String> - Name of object to delete
        #
        def delete_bucket(bucket)
          location = get_bucket_location(bucket)
          endpoint = "http://"+location+".aliyuncs.com"
          resource = bucket+'/'
          request(
            :expects  => 204,
            :method   => 'DELETE',
            :bucket   => bucket,
            :resource => resource,
            :endpoint => endpoint
          )
        end
      end
      
      class Mock
        def delete_bucket(bucket)
        end
      end
    end
  end
end
