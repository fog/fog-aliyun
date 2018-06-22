# frozen_string_literal: true

module Fog
  module Storage
    class Aliyun
      class Real
        def get_bucket(bucket)
          location = get_bucket_location(bucket)
          endpoint = 'http://' + location + '.aliyuncs.com'
          resource = bucket + '/'
          ret = request(
            expects: [200, 203],
            method: 'GET',
            bucket: bucket,
            resource: resource,
            endpoint: endpoint
          )
          xml = ret.data[:body]
          XmlSimple.xml_in(xml)
        end

        def get_bucket_location(bucket)
          attribute = '?location'
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

        def get_bucket_acl(bucket)
          location = get_bucket_location(bucket)
          endpoint = 'http://' + location + '.aliyuncs.com'
          attribute = '?acl'
          resource = bucket + '/' + attribute
          ret = request(
            expects: [200, 203],
            method: 'GET',
            path: attribute,
            bucket: bucket,
            resource: resource,
            endpoint: endpoint
          )
          XmlSimple.xml_in(ret.data[:body])['AccessControlList'][0]['Grant'][0]
        end

        def get_bucket_CORSRules(bucket)
          location = get_bucket_location(bucket)
          endpoint = 'http://' + location + '.aliyuncs.com'
          attribute = '?cors'
          resource = bucket + '/' + attribute
          ret = request(
            expects: [200, 203, 404],
            method: 'GET',
            path: attribute,
            bucket: bucket,
            resource: resource,
            endpoint: endpoint
          )
          XmlSimple.xml_in(ret.data[:body])['CORSRule'][0] if ret.data[:status] != 404
        end

        def get_bucket_lifecycle(bucket)
          location = get_bucket_location(bucket)
          endpoint = 'http://' + location + '.aliyuncs.com'
          attribute = '?lifecycle'
          resource = bucket + '/' + attribute
          ret = request(
            expects: [200, 203, 404],
            method: 'GET',
            path: attribute,
            bucket: bucket,
            resource: resource,
            endpoint: endpoint
          )
          XmlSimple.xml_in(ret.data[:body])['Rule'][0] if ret.data[:status] != 404
        end

        def get_bucket_logging(bucket)
          location = get_bucket_location(bucket)
          endpoint = 'http://' + location + '.aliyuncs.com'
          attribute = '?logging'
          resource = bucket + '/' + attribute
          ret = request(
            expects: [200, 203],
            method: 'GET',
            path: attribute,
            bucket: bucket,
            resource: resource,
            endpoint: endpoint
          )
          XmlSimple.xml_in(ret.data[:body])['LoggingEnabled'][0]['TargetPrefix']
        end

        def get_bucket_referer(bucket)
          location = get_bucket_location(bucket)
          endpoint = 'http://' + location + '.aliyuncs.com'
          attribute = '?referer'
          resource = bucket + '/' + attribute
          ret = request(
            expects: [200, 203],
            method: 'GET',
            path: attribute,
            bucket: bucket,
            resource: resource,
            endpoint: endpoint
          )
          XmlSimple.xml_in(ret.data[:body])
        end

        def get_bucket_website(bucket)
          location = get_bucket_location(bucket)
          endpoint = 'http://' + location + '.aliyuncs.com'
          attribute = '?website'
          resource = bucket + '/' + attribute
          ret = request(
            expects: [200, 203, 404],
            method: 'GET',
            path: attribute,
            bucket: bucket,
            resource: resource,
            endpoint: endpoint
          )
          XmlSimple.xml_in(ret.data[:body]) if ret.data[:status] != 404
        end
      end
    end
  end
end
