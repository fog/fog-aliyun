# frozen_string_literal: true

module Fog
  module Aliyun
    class Storage
      class Real
        # Delete an existing object
        #
        # ==== Parameters
        # * object<~String> - Name of object to delete
        #
        def delete_object(object, options = {})
          bucket = options[:bucket]
          bucket ||= @aliyun_oss_bucket
          resource = bucket + '/' + object
          request(
            expects: 204,
            method: 'DELETE',
            path: object,
            bucket: bucket,
            resource: resource,
            location: get_bucket_location(bucket)
          )
        end

        def abort_multipart_upload(bucket, object, endpoint, uploadid)
          path = object + '?uploadId=' + uploadid
          resource = bucket + '/' + path

          ret = request(
            expects: 204,
            method: 'DELETE',
            path: path,
            bucket: bucket,
            resource: resource,
            endpoint: endpoint,
            location: get_bucket_location(bucket)
          )
        end
      end
    end
  end
end
