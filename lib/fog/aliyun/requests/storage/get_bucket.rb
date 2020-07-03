# frozen_string_literal: true

module Fog
  module Aliyun
    class Storage
      class Real
        def bucket_exists?(bucket_name)
          @oss_client.bucket_exists?(bucket_name)
        end

        def get_bucket(bucket, options = {})
          prefix = options['prefix']
          marker = options['marker']
          # Set the GetBucket max limitation to 1000
          maxKeys = options['max-keys'] || 1000
          maxKeys = maxKeys.to_i
          maxKeys = [maxKeys, 1000].min.to_s
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
            expects: [200, 203, 404],
            method: 'GET',
            bucket: bucket,
            resource: resource,
            path: path
          )
          xml = ret.data[:body]
          XmlSimple.xml_in(xml)
        end

        def get_bucket_acl(bucket)
          attribute = '?acl'
          resource = bucket + '/' + attribute
          ret = request(
            expects: [200, 203],
            method: 'GET',
            path: attribute,
            bucket: bucket,
            resource: resource
          )
          XmlSimple.xml_in(ret.data[:body])['AccessControlList'][0]['Grant'][0]
        end

        def get_bucket_CORSRules(bucket)
          attribute = '?cors'
          resource = bucket + '/' + attribute
          ret = request(
            expects: [200, 203, 404],
            method: 'GET',
            path: attribute,
            bucket: bucket,
            resource: resource
          )
          XmlSimple.xml_in(ret.data[:body])['CORSRule'][0] if ret.data[:status] != 404
        end

        def get_bucket_lifecycle(bucket)
          attribute = '?lifecycle'
          resource = bucket + '/' + attribute
          ret = request(
            expects: [200, 203, 404],
            method: 'GET',
            path: attribute,
            bucket: bucket,
            resource: resource
          )
          XmlSimple.xml_in(ret.data[:body])['Rule'][0] if ret.data[:status] != 404
        end

        def get_bucket_logging(bucket)
          attribute = '?logging'
          resource = bucket + '/' + attribute
          ret = request(
            expects: [200, 203],
            method: 'GET',
            path: attribute,
            bucket: bucket,
            resource: resource
          )
          XmlSimple.xml_in(ret.data[:body])['LoggingEnabled'][0]['TargetPrefix']
        end

        def get_bucket_referer(bucket)
          attribute = '?referer'
          resource = bucket + '/' + attribute
          ret = request(
            expects: [200, 203],
            method: 'GET',
            path: attribute,
            bucket: bucket,
            resource: resource
          )
          XmlSimple.xml_in(ret.data[:body])
        end

        def get_bucket_website(bucket)
          attribute = '?website'
          resource = bucket + '/' + attribute
          ret = request(
            expects: [200, 203, 404],
            method: 'GET',
            path: attribute,
            bucket: bucket,
            resource: resource
          )
          XmlSimple.xml_in(ret.data[:body]) if ret.data[:status] != 404
        end
      end
    end
  end
end
