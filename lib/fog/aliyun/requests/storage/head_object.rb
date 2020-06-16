# frozen_string_literal: true

module Fog
  module Aliyun
    class Storage
      class Real
        # Get headers for object
        #
        # ==== Parameters
        # * object<~String> - Name of object to look for
        # Return a Object, example:
        # key: test_dir/test_file1, type: Normal, size: 0, etag: "D41D8CD98F0xxxxxxxx", metas: {}, last_modified: 2020-06-10 11:51:40 +0000, headers: {:server=>"AliyunOSS", :date=>"Wed, 10 Jun 2020 11:51:41 GMT", :content_type=>"application/octet-stream", :content_length=>"0", :connection=>"keep-alive", :x_oss_request_id=>"5EE0C94DE367xxxxxxxxxxx", :accept_ranges=>"bytes", :etag=>"\"D41D8CD98F00B20xxxxxxxxxxx\"", :last_modified=>"Wed, 10 Jun 2020 11:51:40 GMT", :x_oss_object_type=>"Normal", :x_oss_hash_crc64ecma=>"0", :x_oss_storage_class=>"Standard", :content_md5=>"1B2M2Y8Asgxxxxxxfg==", :x_oss_server_time=>"8"}
        #
        def head_object(object, options = {})
          bucket_name = options[:bucket]
          bucket_name ||= @aliyun_oss_bucket
          bucket = @oss_client.get_bucket(bucket_name)
          obj = bucket.get_object(object)
          puts "888888888888888888 obj #{obj}"
          obj
        end
      end
    end
  end
end
