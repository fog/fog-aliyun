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
          bucket_name = options[:bucket]
          bucket_name ||= @aliyun_oss_bucket
          bucket = @oss_client.get_bucket(bucket_name)
          bucket.delete_object(object)
        end

        def abort_multipart_upload(bucket_name, object, upload_id)
          bucket = @oss_client.get_bucket(bucket_name)
          bucket.abort_upload(upload_id, object)
        end
      end
    end
  end
end
