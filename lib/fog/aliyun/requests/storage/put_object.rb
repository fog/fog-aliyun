# frozen_string_literal: true

module Fog
  module Storage
    class Aliyun
      class Real
        # Put details for object
        #
        # ==== Parameters
        # * object<~String> - Name of object to look for
        #
        def put_object(object, file = nil, options = {})
          bucket = options[:bucket]
          bucket ||= @aliyun_oss_bucket
          location = get_bucket_location(bucket)
          endpoint = 'http://' + location + '.aliyuncs.com'
          return put_folder(bucket, object, endpoint) if file.nil?

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
            endpoint: endpoint
          )
        end

        def put_object_with_body(object, body, options = {})
          bucket = options[:bucket]
          bucket ||= @aliyun_oss_bucket
          location = get_bucket_location(bucket)
          endpoint = 'http://' + location + '.aliyuncs.com'

          resource = bucket + '/' + object
          request(
            expects: [200, 203],
            method: 'PUT',
            path: object,
            bucket: bucket,
            resource: resource,
            body: body,
            endpoint: endpoint
          )
        end

        def put_folder(bucket, folder, endpoint)
          if endpoint.nil?
            location = get_bucket_location(bucket)
            endpoint = 'http://' + location + '.aliyuncs.com'
          end
          path = folder + '/'
          resource = bucket + '/' + folder + '/'
          request(
            expects: [200, 203],
            method: 'PUT',
            path: path,
            bucket: bucket,
            resource: resource,
            endpoint: endpoint
          )
        end

        def put_multipart_object(bucket, object, file)
          location = get_bucket_location(bucket)
          endpoint = 'http://' + location + '.aliyuncs.com'

          # find the right uploadid
          uploads = list_multipart_uploads(bucket, endpoint)
          upload = (uploads&.find { |tmpupload| tmpupload['Key'][0] == object })

          uploadedSize = 0
          start_partNumber = 1
          if !upload.nil?
            uploadId = upload['UploadId'][0]
            parts = list_parts(bucket, object, endpoint, uploadId)
            if !parts.nil? && !parts.empty?
              if parts[-1]['Size'][0].to_i != 5_242_880
                # the part is the last one, if its size is over 5m, then finish this upload
                complete_multipart_upload(bucket, object, endpoint, uploadId)
                return
              end
              uploadedSize = (parts[0]['Size'][0].to_i * (parts.size - 1)) + parts[-1]['Size'][0].to_i
              start_partNumber = parts[-1]['PartNumber'][0].to_i + 1
            end
          else
            # create upload ID
            uploadId = initiate_multipart_upload(bucket, object, endpoint)
          end

          if file.size <= uploadedSize
            complete_multipart_upload(bucket, object, endpoint, uploadId)
            return
          end

          end_partNumber = (file.size + 5_242_880 - 1) / 5_242_880
          file.seek(uploadedSize)

          for i in start_partNumber..end_partNumber
            body = file.read(5_242_880)
            upload_part(bucket, object, endpoint, i.to_s, uploadId, body)
          end

          complete_multipart_upload(bucket, object, endpoint, uploadId)
        end

        def initiate_multipart_upload(bucket, object, endpoint)
          if endpoint.nil?
            location = get_bucket_location(bucket)
            endpoint = 'http://' + location + '.aliyuncs.com'
          end
          path = object + '?uploads'
          resource = bucket + '/' + path
          ret = request(
            expects: 200,
            method: 'POST',
            path: path,
            bucket: bucket,
            resource: resource,
            endpoint: endpoint
          )
          XmlSimple.xml_in(ret.data[:body])['UploadId'][0]
        end

        def upload_part(bucket, object, endpoint, partNumber, uploadId, body)
          if endpoint.nil?
            location = get_bucket_location(bucket)
            endpoint = 'http://' + location + '.aliyuncs.com'
          end
          path = object + '?partNumber=' + partNumber + '&uploadId=' + uploadId
          resource = bucket + '/' + path
          request(
            expects: [200, 203],
            method: 'PUT',
            path: path,
            bucket: bucket,
            resource: resource,
            body: body,
            endpoint: endpoint
          )
        end

        def complete_multipart_upload(bucket, object, endpoint, uploadId)
          if endpoint.nil?
            location = get_bucket_location(bucket)
            endpoint = 'http://' + location + '.aliyuncs.com'
          end
          parts = list_parts(bucket, object, endpoint, uploadId, options = {})
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
            endpoint: endpoint,
            body: body
          )
        end
      end
    end
  end
end
