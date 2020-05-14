# frozen_string_literal: true

require 'fog/core/model'
require 'fog/aliyun/models/storage/files'

module Fog
  module Aliyun
    class Storage
      class Directory < Fog::Model
        identity :key, :aliases => ['Key', 'Name', 'name']

        def destroy
          requires :key
          prefix = key + '/'
          ret = service.list_objects(prefix: prefix)['Contents']

          if ret.nil?
            false
          elsif ret.size == 1
            service.delete_container(key)
            true
          else
            raise Fog::Aliyun::Storage::Error, ' Forbidden: Direction not empty!'
            false
          end
        end

        def files
          @files ||= begin
            Fog::Aliyun::Storage::Files.new(
              directory: self,
              service: service
            )
          end
        end

        def public_url
          nil
        end

        def save
          requires :key

          # Checking whether the key is a bucket and meet the multi-bucket scenario.
          # If the key is a existing bucket, return it directly.
          key = key.chomp('/')
          if !key.nil? && key != '' && key != '.' && !(key.include? '/')
            data = service.get_bucket(key)
            if data.class == Hash && data.key?('Code') && !data['Code'].nil? && !data['Code'].empty?
              service.put_container(key)
            end
          end

          true
        end
      end
    end
  end
end
