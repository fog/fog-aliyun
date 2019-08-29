# frozen_string_literal: true

module Fog
  module Storage
    class Aliyun
      class Real
        def get_bucket(bucket)
          endpoint = get_bucket_endpoint(bucket)
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

        def get_bucket_endpoint(bucket)
          location = get_bucket_location(bucket)
          # If the endpoint specified contains with -internal, then assume it is a vpc endpoint, 
          # hence, the bucket endpoint returned is also internal one...
          # Otherwise, continue to use the public endpoint as previous edition.
          if @aliyun_oss_endpoint.downcase()['-internal']
            endpoint = 'http://' + location + '-internal'+'.aliyuncs.com'
          else
            endpoint = 'http://' + location +'.aliyuncs.com'
          end     
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
          endpoint = get_bucket_endpoint(bucket)
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
          endpoint = get_bucket_endpoint(bucket)
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
          endpoint = get_bucket_endpoint(bucket)
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
          endpoint = get_bucket_endpoint(bucket)
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
          endpoint = get_bucket_endpoint(bucket)
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
          endpoint = get_bucket_endpoint(bucket)
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
