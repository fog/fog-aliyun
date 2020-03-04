# frozen_string_literal: true

require 'fog/core/collection'
require 'fog/aliyun/models/storage/directory'

module Fog
  module Storage
    class Aliyun
      class Directories < Fog::Collection
        model Fog::Storage::Aliyun::Directory

        def all
          containers = service.get_containers
          return nil if containers.nil?
          data = []
          i = 0
          containers.each do |entry|
            key = entry['Prefix'][0]
            key[-1] = ''
            data[i] = { key: key }
            i += 1
          end

          load(data)
        end

        # get method used to get a specified directory.
        # If the directory is not exist, this method will create a new with 'key'
        # In order to support multi-buckets scenario which making bucket as a solo directory, it have been expanded.
        # If key is a directory(including /), return an existed or a new one;
        # If key does not contain /, if bucket, return '', else return an existed or a new one directory;
        def get(key, options = {})
          if !key.nil? && key != '' && key != '.'
            if key.include? '/'
              dir = key + '/'
              ret = service.head_object(dir, options)
              new(key: key) if ret.data[:status] == 200
            else
              data = service.get_bucket(key)
              if data[:status] == 404
                dir = key + '/'
                ret = service.head_object(dir, options)
                new(key: key) if ret.data[:status] == 200
              else
                new(key: '')
              end
            end
          else
            new(key: '')
          end
        rescue Fog::Storage::Aliyun::NotFound
          nil
        end
      end
    end
  end
end
