# frozen_string_literal: true

module Fog
  module Aliyun
    class Storage
      class Real
        # Get details for object
        #
        # ==== Parameters
        # * object<~String> - Name of object to look for
        #
        def get_object(object, range = nil, options = {})
          options = options.reject { |_key, value| value.nil? }
          bucket_name = options[:bucket]
          bucket_name ||= @aliyun_oss_bucket
          # Using OSS ruby SDK to fix performance issue
          bucket = @oss_client.get_bucket(bucket_name)
          body = Array.new
          obj = bucket.get_object(object) do |chunk|
            body << chunk
          end
          response = {}
          obj.instance_variables.each {|var| response[var.to_s.delete("@")] = obj.instance_variable_get(var) }
          response.merge({:body => body.join('')})
        end
      end
    end
  end
end
