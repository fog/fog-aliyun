# frozen_string_literal: true

module Fog
  module Aliyun
    class Storage
      class Real
        def bucket_exists?(bucket_name)
          @oss_client.bucket_exists?(bucket_name)
        end

        def get_bucket(bucket_name, options = {})
          unless bucket_name
            raise ArgumentError.new('bucket_name is required')
          end

          # Set the GetBucket max limitation to 1000
          maxKeys = options[:max_keys] || 1000
          maxKeys = maxKeys.to_i
          maxKeys = [maxKeys, 1000].min

          options[:limit] = maxKeys
          options.delete(:max_keys)

          @oss_protocol.list_objects(bucket_name, options)
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
