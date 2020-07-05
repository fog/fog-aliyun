# frozen_string_literal: true

module Fog
  module Aliyun
    class Storage
      class Real
        # Get headers for object
        #
        # ==== Parameters
        # * object<~String> - Name of object to look for
        #
        def head_object(object, options = {})
          bucket_name = options[:bucket]
          bucket_name ||= @aliyun_oss_bucket
          # Using OSS ruby SDK to fix performance issue
          @oss_http.head({:bucket => bucket_name, :object => object}, {})
        end
      end
    end
  end
end
