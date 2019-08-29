# frozen_string_literal: true

module Fog
  module Storage
    class Aliyun
      class Real
        # Delete an existing object
        #
        # ==== Parameters
        # * object<~String> - Name of object to delete
        #
        def delete_object(object, options = {})
          bucket = options[:bucket]
          bucket ||= @aliyun_oss_bucket
          endpoint = options[:endpoint]
          if endpoint.nil?
            endpoint = get_bucket_endpoint(bucket)
          end
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

        def abort_multipart_upload(bucket, object, endpoint, uploadid)
          if endpoint.nil?
            endpoint = get_bucket_endpoint(bucket)
          end
          path = object + '?uploadId=' + uploadid
          resource = bucket + '/' + path

          ret = request(
            expects: 204,
            method: 'DELETE',
            path: path,
            bucket: bucket,
            resource: resource,
            endpoint: endpoint
          )
        end
      end
    end
  end
end
