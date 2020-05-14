# frozen_string_literal: true

require 'fog/core/collection'
require 'fog/aliyun/models/storage/directory'

module Fog
  module Aliyun
    class Storage
      class Directories < Fog::Collection
        model Fog::Aliyun::Storage::Directory

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
          if key.is_a? Array
            key = key[0]
          end
          if !key.nil? && key != '' && key != '.'
            key = key.chomp('/')
            if key.include? '/'
              dir = key + '/'
              ret = service.head_object(dir, options)
              new(key: key) if ret.data[:status] == 200
            else
              remap_attributes(options, {
                  :delimiter  => 'delimiter',
                  :marker     => 'marker',
                  :max_keys   => 'max-keys',
                  :prefix     => 'prefix'
              })
              data = service.get_bucket(key, options)
              directory = new(:key => data['Name'], :is_persisted => true)
              options = {}
              for k, v in data
                if ['CommonPrefixes', 'Delimiter', 'IsTruncated', 'Marker', 'MaxKeys', 'Prefix'].include?(k)
                  # Sometimes, the v will be a Array, like "Name"=>["blobstore-droplet1"], "Prefix"=>[{}], "Marker"=>[{}], "MaxKeys"=>["100"], "Delimiter"=>[{}], "IsTruncated"=>["false"]
                  # and there needs to parse them
                  if !v.nil? && (v.is_a? Array) && (v.size > 0)
                    if v[0].is_a? Hash
                      v = nil
                    else
                      v = v[0]
                    end
                  end
                  options[k] = v
                end
              end
              directory.files.merge_attributes(options)
              if data.key?('Contents') && !data['Contents'].nil?
                directory.files.load(data['Contents'])
              end
              directory
            end
          else
            new(key: '')
          end
        rescue Fog::Aliyun::Storage::NotFound
          nil
        end
      end
    end
  end
end
