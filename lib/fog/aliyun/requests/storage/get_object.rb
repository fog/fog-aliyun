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
        def get_object(object, options = {}, &block)
          options = options.reject { |_key, value| value.nil? }
          bucket_name = options[:bucket]
          bucket_name ||= @aliyun_oss_bucket
          options.delete(:bucket)
          # Using OSS ruby SDK to fix performance issue
          params = { :headers => {} }
          params[:query] = options.delete('query') || {}

          params[:headers].merge!(options)
          if options['If-Modified-Since']
            params[:headers]['If-Modified-Since'] = Fog::Time.at(options['If-Modified-Since'].to_i).to_date_header
          end
          if options['If-Unmodified-Since']
            params[:headers]['If-Unmodified-Since'] = Fog::Time.at(options['If-Unmodified-Since'].to_i).to_date_header
          end

          if block_given?
            params[:response_block] = Proc.new
          end

          @oss_http.get({:bucket => bucket_name, :object => object}, params, &block)

        end
      end
    end
  end
end
