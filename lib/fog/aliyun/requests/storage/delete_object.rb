# frozen_string_literal: true

module Fog
  module Aliyun
    class Storage
      class Real
        # Delete an existing object
        #
        # ==== Parameters
        # * object_name<~String> - Name of object to delete
        #
        def delete_object(bucket_name, object_name, options = {})
          # TODO Support versionId
          # if version_id = options.delete('versionId')
          #   query = {'versionId' => version_id}
          # else
          #   query = {}
          # end

          @oss_http.delete({:bucket => bucket_name, :object => object_name}, {:headers => options})

        end

        def abort_multipart_upload(bucket_name, object, upload_id)
          bucket = @oss_client.get_bucket(bucket_name)
          bucket.abort_upload(upload_id, object)
        end
      end
    end
  end
end
