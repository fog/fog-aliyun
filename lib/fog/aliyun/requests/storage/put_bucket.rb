# frozen_string_literal: true

module Fog
  module Storage
    class Aliyun
      class Real
        def put_bucket(bucketName)
          resource = bucketName + '/'
          request(
            expects: [200, 203],
            method: 'PUT',
            resource: resource,
            bucket: bucketName
          )
        end
      end
    end
  end
end
