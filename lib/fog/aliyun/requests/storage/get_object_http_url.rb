# frozen_string_literal: true

module Fog
  module Storage
    class Aliyun
      class Real
        # Get an expiring object http url
        #
        # ==== Parameters
        # * container<~String> - Name of container containing object
        # * object<~String> - Name of object to get expiring url for
        # * expires<~Integer> - An expiry time for this url
        #
        # ==== Returns
        # * response<~Excon::Response>:
        #   * body<~String> - url for object
        def get_object_http_url_public(object, expires, options = {})
          options = options.reject { |_key, value| value.nil? }
          bucket = options[:bucket]
          bucket ||= @aliyun_oss_bucket
          acl = get_bucket_acl(bucket)
          location = get_bucket_location(bucket)

          if acl == 'private'
            expires_time = (Time.now.to_i + expires).to_s
            resource = bucket + '/' + object
            signature = sign('GET', expires_time, nil, resource)
            'http://' + bucket + '.' + location + '.aliyuncs.com/' + object +
              '?OSSAccessKeyId=' + @aliyun_accesskey_id + '&Expires=' + expires_time +
              '&Signature=' + URI.encode(signature, '/[^!*\'()\;?:@#&%=+$,{}[]<>`" ')
          elsif acl == 'public-read' || acl == 'public-read-write'
            'http://' + bucket + '.' + location + '.aliyuncs.com/' + object
          else
            'acl is wrong with value:' + acl
          end
        end
      end
    end
  end
end
