# frozen_string_literal: true

module Fog
  module Aliyun
    class Storage
      class Real
        # Get an expiring object https url from Cloud Files
        #
        # ==== Parameters
        # * container<~String> - Name of container containing object
        # * object<~String> - Name of object to get expiring url for
        # * expires<~Integer> - An expiry time for this url
        #
        # ==== Returns
        # * response<~Excon::Response>:
        #   * body<~String> - url for object
        def get_object_https_url_public(object, expires, options = {})
          options = options.reject { |_key, value| value.nil? }
          bucket_name = options[:bucket]
          bucket_name ||= @aliyun_oss_bucket
          bucket = @oss_client.get_bucket(bucket_name)
          acl = bucket.acl()

          if acl == 'private'
            expires_time = (Time.now.to_i + (expires.nil? ? 0 : expires.to_i)).to_s
            resource = bucket_name + '/' + object
            signature = sign('GET', expires_time, nil, resource)
            'https://' + bucket_name + '.' + @host + '/' + object +
              '?OSSAccessKeyId=' + @aliyun_accesskey_id + '&Expires=' + expires_time +
              '&Signature=' + URI.encode(signature, '/[^!*\'()\;?:@#&%=+$,{}[]<>`" ')
          elsif acl == 'public-read' || acl == 'public-read-write'
            'https://' + bucket_name + '.' + @host + '/' + object
          else
            'acl is wrong with value:' + acl
          end
        end
      end
    end
  end
end
