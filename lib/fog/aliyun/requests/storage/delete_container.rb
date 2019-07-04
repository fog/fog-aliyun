# frozen_string_literal: true

module Fog
  module Storage
    class Aliyun
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
          endpoint = options[:endpoint]
          if endpoint.nil?
            endpoint = get_bucket_endpoint(bucket)
          end
          object = container + '/'
          resource = bucket + '/' + object

          request(
            expects: 204,
            method: 'DELETE',
            path: object,
            bucket: bucket,
            resource: resource,
            endpoint: endpoint
          )
        end
      end
    end
  end
end
