# frozen_string_literal: true

module Fog
  module Aliyun
    class Storage
      class Real
        # Put details for object
        #
        # ==== Parameters
        # * object<~String> - Name of object to look for
        #
        def put_object(object, file = nil, options = {})
          bucket_name = options[:bucket]
          bucket_name ||= @aliyun_oss_bucket
          bucket = @oss_client.get_bucket(bucket_name)
          return bucket.put_object(object) if file.nil?
          # With a single PUT operation you can upload objects up to 5 GB in size.
          if file.size > 5_368_709_120
            bucket.resumable_upload(object, file.path)
          end
          bucket.put_object(object, :file => file.path)
        end

        def put_object_with_body(object, body, options = {})
          bucket_name = options[:bucket]
          bucket_name ||= @aliyun_oss_bucket

          resource = bucket_name + '/' + object
          request(
            expects: [200, 203],
            method: 'PUT',
            path: object,
            bucket: bucket_name,
            resource: resource,
            body: body
          )
        end

        def put_folder(bucket, folder)
          path = folder + '/'
          resource = bucket + '/' + folder + '/'
          request(
            expects: [200, 203],
            method: 'PUT',
            path: path,
            bucket: bucket,
            resource: resource
          )
        end

        def put_multipart_object(bucket, object, file)
          # find the right uploadid
          uploads = list_multipart_uploads(bucket)
          upload = (uploads&.find { |tmpupload| tmpupload['Key'][0] == object })

          uploadedSize = 0
          start_partNumber = 1
          if !upload.nil?
            uploadId = upload['UploadId'][0]
            parts = list_parts(bucket, object, uploadId)
            if !parts.nil? && !parts.empty?
              if parts[-1]['Size'][0].to_i != 5_242_880
                # the part is the last one, if its size is over 5m, then finish this upload
                complete_multipart_upload(bucket, object, uploadId)
                return
              end
              uploadedSize = (parts[0]['Size'][0].to_i * (parts.size - 1)) + parts[-1]['Size'][0].to_i
              start_partNumber = parts[-1]['PartNumber'][0].to_i + 1
            end
          else
            # create upload ID
            uploadId = initiate_multipart_upload(bucket, object)
          end

          if file.size <= uploadedSize
            complete_multipart_upload(bucket, object, uploadId)
            return
          end

          end_partNumber = (file.size + 5_242_880 - 1) / 5_242_880
          file.seek(uploadedSize)

          for i in start_partNumber..end_partNumber
            body = file.read(5_242_880)
            upload_part(bucket, object, i.to_s, uploadId, body)
          end

          complete_multipart_upload(bucket, object, uploadId)
        end

        def initiate_multipart_upload(bucket, object)
          path = object + '?uploads'
          resource = bucket + '/' + path
          ret = request(
            expects: 200,
            method: 'POST',
            path: path,
            bucket: bucket,
            resource: resource
          )
          XmlSimple.xml_in(ret.data[:body])['UploadId'][0]
        end

        def upload_part(bucket, object, partNumber, uploadId, body)
          path = object + '?partNumber=' + partNumber + '&uploadId=' + uploadId
          resource = bucket + '/' + path
          request(
            expects: [200, 203],
            method: 'PUT',
            path: path,
            bucket: bucket,
            resource: resource,
            body: body
          )
        end

        def complete_multipart_upload(bucket, object, uploadId)
          parts = list_parts(bucket, object, uploadId, options = {})
          request_part = []
          return if parts.empty?
          for i in 0..(parts.size - 1)
            part = parts[i]
            request_part[i] = { 'PartNumber' => part['PartNumber'], 'ETag' => part['ETag'] }
          end
          body = XmlSimple.xml_out({ 'Part' => request_part }, 'RootName' => 'CompleteMultipartUpload')

          path = object + '?uploadId=' + uploadId
          resource = bucket + '/' + path
          request(
            expects: 200,
            method: 'POST',
            path: path,
            bucket: bucket,
            resource: resource,
            body: body
          )
        end
      end
    end
  end
end
