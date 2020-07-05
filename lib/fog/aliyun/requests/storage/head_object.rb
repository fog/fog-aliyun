# frozen_string_literal: true

module Fog
  module Aliyun
    class Storage
      class Real
        # Get headers for object
        #
        # ==== Parameters
        # * object<~String> - Name of object to look for
        #
        def head_object(object, options = {})
          bucket_name = options[:bucket]
          bucket_name ||= @aliyun_oss_bucket
          resource = bucket_name + '/' + object
          ret = request(
            expects: [200, 404],
            method: 'HEAD',
            path: object,
            bucket: bucket_name,
            resource: resource
          )
          ret
        end
      end
    end
  end
end
