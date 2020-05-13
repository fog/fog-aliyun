# frozen_string_literal: true

module Fog
  module Storage
    class Aliyun
      class Real
        # Delete an existing bucket
        #
        # ==== Parameters
        # * bucket<~String> - Name of bucket to delete
        #
        def delete_bucket(bucket)
          resource = bucket + '/'
          request(
            expects: 204,
            method: 'DELETE',
            bucket: bucket,
            resource: resource,
            location: get_bucket_location(bucket)
          )
        end
      end
    end
  end
end
