# frozen_string_literal: true

module Fog
  module Aliyun
    class Storage
      class Real
        # Create a new container
        #
        # ==== Parameters
        # * name<~String> - Name for container
        #
        def put_container(name, options = {})
          bucket = options[:bucket]
          bucket ||= @aliyun_oss_bucket

          path = name + '/'
          resource = bucket + '/' + name + '/'
          request(
            expects: [200, 203],
            method: 'PUT',
            path: path,
            bucket: bucket,
            resource: resource
          )
        end
      end
    end
  end
end
