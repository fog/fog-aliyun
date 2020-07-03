# frozen_string_literal: true

module Fog
  module Aliyun
    class Storage
      class Real
        def list_objects(options = {})
          bucket = options['bucket']
          bucket ||= @aliyun_oss_bucket
          prefix = options['prefix']
          marker = options['marker']
          # Set the ListObjects max limitation to 1000
          maxKeys = options[:maxKeys]||1000
          maxKeys = maxKeys.to_i
          maxKeys = [maxKeys,1000].min.to_s
          delimiter = options['delimiter']

          path = ''
          if prefix
            path += '/?prefix=' + prefix
            path += '&marker=' + marker if marker
            path += '&max-keys=' + maxKeys if maxKeys
            path += '&delimiter=' + delimiter if delimiter

          elsif marker
            path += '/?marker=' + marker
            path += '&max-keys=' + maxKeys if maxKeys
            path += '&delimiter=' + delimiter if delimiter

          elsif maxKeys
            path += '/?max-keys=' + maxKeys
            path += '&delimiter=' + delimiter if delimiter
          elsif delimiter
            path += '/?delimiter=' + delimiter
          end

          resource = bucket + '/'
          ret = request(
            expects: [200, 203, 400],
            method: 'GET',
            path: path,
            resource: resource,
            bucket: bucket
          )
          xml = ret.data[:body]
          XmlSimple.xml_in(xml)
        end

        def list_multipart_uploads(bucket, _options = {})
          path = '?uploads'
          resource = bucket + '/' + path

          ret = request(
            expects: 200,
            method: 'GET',
            path: path,
            bucket: bucket,
            resource: resource
          )
          XmlSimple.xml_in(ret.data[:body])['Upload']
        end

        def list_parts(bucket, object, uploadid, _options = {})
          path = object + '?uploadId=' + uploadid
          resource = bucket + '/' + path

          ret = request(
            expects: 200,
            method: 'GET',
            path: path,
            bucket: bucket,
            resource: resource
          )
          XmlSimple.xml_in(ret.data[:body])['Part']
        end
      end
    end
  end
end
