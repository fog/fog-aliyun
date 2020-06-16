# frozen_string_literal: true

module Fog
  module Aliyun
    class Storage
      class Real
        # Delete an existing container
        #
        # ==== Parameters
        # * container<~String> - Name of container to delete
        # * options
        #
        def delete_container(container, options = {})
          bucket = options[:bucket]
          bucket ||= @aliyun_oss_bucket
          object = container + '/'
          resource = bucket + '/' + object

          request(
            expects: 204,
            method: 'DELETE',
            path: object,
            bucket: bucket,
            resource: resource
          )
        end
      end
    end
  end
end
