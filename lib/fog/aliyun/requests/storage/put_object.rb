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
          bucket = options[:bucket]
          bucket ||= @aliyun_oss_bucket
          return put_folder(bucket, object) if file.nil?

          # put multiparts if object's size is over 100m
          return put_multipart_object(bucket, object, file) if file.size > 104_857_600

          body = file.read

          resource = bucket + '/' + object
          request(
            expects: [200, 203],
            method: 'PUT',
            path: object,
            bucket: bucket,
            resource: resource,
            body: body,
            location: get_bucket_location(bucket)
          )
        end

        def put_object_with_body(object, body, options = {})
          bucket = options[:bucket]
          bucket ||= @aliyun_oss_bucket

          resource = bucket + '/' + object
          request(
            expects: [200, 203],
            method: 'PUT',
            path: object,
            bucket: bucket,
            resource: resource,
            body: body,
            location: get_bucket_location(bucket)
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
            resource: resource,
            location: get_bucket_location(bucket)
          )
        end

        def put_multipart_object(bucket, object, file)
          location = get_bucket_location(bucket)

          # find the right uploadid
          uploads = list_multipart_uploads(bucket, location)
          upload = (uploads&.find { |tmpupload| tmpupload['Key'][0] == object })

          uploadedSize = 0
          start_partNumber = 1
          if !upload.nil?
            uploadId = upload['UploadId'][0]
            parts = list_parts(bucket, object, location, uploadId)
            if !parts.nil? && !parts.empty?
              if parts[-1]['Size'][0].to_i != 5_242_880
                # the part is the last one, if its size is over 5m, then finish this upload
                complete_multipart_upload(bucket, object, location, uploadId)
                return
              end
              uploadedSize = (parts[0]['Size'][0].to_i * (parts.size - 1)) + parts[-1]['Size'][0].to_i
              start_partNumber = parts[-1]['PartNumber'][0].to_i + 1
            end
          else
            # create upload ID
            uploadId = initiate_multipart_upload(bucket, object, location)
          end

          if file.size <= uploadedSize
            complete_multipart_upload(bucket, object, location, uploadId)
            return
          end

          end_partNumber = (file.size + 5_242_880 - 1) / 5_242_880
          file.seek(uploadedSize)

          for i in start_partNumber..end_partNumber
            body = file.read(5_242_880)
            upload_part(bucket, object, location, i.to_s, uploadId, body)
          end

          complete_multipart_upload(bucket, object, location, uploadId)
        end

        def initiate_multipart_upload(bucket, object, location)
          location ||= get_bucket_location(bucket)
          path = object + '?uploads'
          resource = bucket + '/' + path
          ret = request(
            expects: 200,
            method: 'POST',
            path: path,
            bucket: bucket,
            resource: resource,
            location: location
          )
          XmlSimple.xml_in(ret.data[:body])['UploadId'][0]
        end

        def upload_part(bucket, object, location, partNumber, uploadId, body)
          location ||= get_bucket_location(bucket)
          path = object + '?partNumber=' + partNumber + '&uploadId=' + uploadId
          resource = bucket + '/' + path
          request(
            expects: [200, 203],
            method: 'PUT',
            path: path,
            bucket: bucket,
            resource: resource,
            body: body,
            location: location
          )
        end

        def complete_multipart_upload(bucket, object, location, uploadId)
          location ||= get_bucket_location(bucket)
          parts = list_parts(bucket, object, location, uploadId, options = {})
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
            location: location,
            body: body
          )
        end
      end
    end
  end
end
