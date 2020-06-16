# frozen_string_literal: true

module Fog
  module Aliyun
    class Storage
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
            resource: resource
          )
        end
      end
    end
  end
end
