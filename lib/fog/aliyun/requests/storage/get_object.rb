# frozen_string_literal: true

module Fog
  module Aliyun
    class Storage
      class Real
        # Get details for object
        #
        # ==== Parameters
        # * object_name<~String> - Name of object to look for
        #
        def get_object(object_name, options = {}, &block)
          options = options.reject { |_key, value| value.nil? }
          bucket_name = options[:bucket]
          bucket_name ||= @aliyun_oss_bucket
          options.delete(:bucket)
          # Using OSS ruby SDK to fix performance issue
          http_options = { :headers => {} }
          http_options[:query] = options.delete('query') || {}

          http_options[:headers].merge!(options)
          if options['If-Modified-Since']
            http_options[:headers]['If-Modified-Since'] = Fog::Time.at(options['If-Modified-Since'].to_i).to_date_header
          end
          if options['If-Unmodified-Since']
            http_options[:headers]['If-Unmodified-Since'] = Fog::Time.at(options['If-Unmodified-Since'].to_i).to_date_header
          end

          if block_given?
            http_options[:response_block] = Proc.new
          end

          resources = {
              :bucket => bucket_name,
              :object => object_name
          }

          @oss_http.get(resources, http_options, &block)

        end
      end
    end
  end
end
