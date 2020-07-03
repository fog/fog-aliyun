# frozen_string_literal: true

require 'fog/core/collection'
require 'fog/aliyun/models/storage/file'
require 'aliyun/oss'

module Fog
  module Aliyun
    class Storage
      class Files < Fog::Collection
        attribute :directory
        attribute :limit
        attribute :prefix,          :aliases => 'Prefix'
        attribute :path
        attribute :common_prefixes, :aliases => 'CommonPrefixes'
        attribute :delimiter,       :aliases => 'Delimiter'
        attribute :is_truncated,    :aliases => 'IsTruncated'
        attribute :marker,          :aliases => 'Marker'
        attribute :max_keys,        :aliases => ['MaxKeys', 'max-keys']

        model Fog::Aliyun::Storage::File

        # check_directory_key have two functions:
        # 1. trim the directory_key suffix '/'
        # 2. checking whether the directory_key is a bucket.
        #    If so, it will return directly to avoid to create a new redundant folder named with directory_key.
        #    This point will be applied to multi-bucket and make bucket as a directory scenario.
        def check_directory_key(directory_key)
          bucket_name = nil
          if directory_key.is_a? Array
            directory_key = directory_key[0]
          end
          if directory_key != ''
            # trim the suffix '/'
            directory_key = directory_key.chomp('/')
            # The bucket name can not contain '/', so if directory_key, return directory.
            if directory_key.include? '/'
              directory_key
            elsif service.bucket_exists?(directory_key)
              bucket_name = directory_key
              directory_key = ''
            else
              directory_key
            end
          end
          return bucket_name, directory_key
        end

        def all(options = {})
          requires :directory
          options = {
              'delimiter'   => delimiter,
              'marker'      => marker,
              'max-keys'    => max_keys.to_i,
              'prefix'      => prefix
          }.merge!(options)
          options = options.reject {|key,value| value.nil? || value.to_s.empty?}
          merge_attributes(options)
          parent = directory.collection.get(
              directory.key,
              options
          )
          if parent
            merge_attributes(parent.files.attributes)
            load(parent.files.map {|file| file.attributes})
          else
            nil
          end
        end

        alias each_file_this_page each
        def each
          if !block_given?
            self
          else
            subset = dup.all

            subset.each_file_this_page { |f| yield f }
            while subset.length == (subset.limit || 10_000)
              subset = subset.all(marker: subset.last.key)
              subset.each_file_this_page { |f| yield f }
            end

            self
          end
        end

        def get(key, options = {}, &block)
          requires :directory
          bucket_name, directory_key = check_directory_key(directory.key)
          object = if directory_key == ''
                     key
                   else
                     directory_key + '/' + key
                   end
          begin
            data = service.get_object(object, options.merge({bucket: bucket_name}), &block)
            headers = data.headers
            lastModified = headers[:last_modified]
            last_modified = (Time.parse(lastModified).localtime if !lastModified.nil? && lastModified != '')

            date = headers[:date]
            date = (Time.parse(date).localtime if !date.nil? && date != '')
            file_data = {
                body: data.body,
                content_length: headers[:content_length].to_i,
                key: key,
                last_modified: last_modified,
                content_type: headers[:content_type],
                etag: headers[:etag],
                date: date,
                connection: headers[:connection],
                accept_ranges: headers[:accept_ranges],
                server: headers[:server],
                object_type: headers[:x_oss_object_type]
            }

            new(file_data)
          rescue AliyunOssSdk::ServerError => error
            case error.error_code
            when %r{NoSuchKey},%r{SymlinkTargetNotExist}
              nil
            else
              raise(error)
            end
          end
        end

        def get_url(key)
          requires :directory
          bucket_name, directory_key = check_directory_key(directory.key)
          object = if directory_key == ''
                     key
                   else
                     directory_key + '/' + key
                   end
          service.get_object_http_url_public(object, 3600, bucket: bucket_name)
        end

        def get_http_url(key, expires, options = {})
          requires :directory
          bucket_name, directory_key = check_directory_key(directory.key)
          object = if directory_key == ''
                     key
                   else
                     directory_key + '/' + key
                   end
          expires = expires.nil? ? 0 : expires.to_i
          service.get_object_http_url_public(object, expires, options.merge(bucket: bucket_name))
        end

        def get_https_url(key, expires, options = {})
          requires :directory
          bucket_name, directory_key = check_directory_key(directory.key)
          object = if directory_key == ''
                     key
                   else
                     directory_key + '/' + key
                   end
          expires = expires.nil? ? 0 : expires.to_i
          service.get_object_https_url_public(object, expires, options.merge(bucket: bucket_name))
        end

        def head(key, _options = {})
          requires :directory
          bucket_name, directory_key = check_directory_key(directory.key)
          object = if directory_key == ''
                     key
                   else
                     directory_key + '/' + key
                   end
          data = service.head_object(object, bucket: bucket_name).data
          return nil if data[:status] == 404
          lastModified = data[:headers]['Last-Modified']
          last_modified = (Time.parse(lastModified).localtime if !lastModified.nil? && lastModified != '')

          date = data[:headers]['Date']
          date = (Time.parse(date).localtime if !date.nil? && date != '')

          file_data = {
            content_length: data[:headers]['Content-Length'].to_i,
            key: key,
            last_modified: last_modified,
            content_type: data[:headers]['Content-Type'],
            etag: data[:headers]['ETag'],
            date: date,
            connection: data[:headers]['Connection'],
            accept_ranges: data[:headers]['Accept-Ranges'],
            server: data[:headers]['Server'],
            object_type: data[:headers]['x-oss-object-type']
          }
          new(file_data)
        rescue Fog::Aliyun::Storage::NotFound
          nil
        end

        def new(attributes = {})
          requires :directory
          # Sometimes, the v will be a Array, like "Prefix"=>[{}], "Marker"=>[xxxx], "MaxKeys"=>["100"], "IsTruncated"=>["false"]
          # and there needs to parse them
          for k, v in attributes
            if !v.nil? && (v.is_a? Array) && (v.size > 0)
              attributes[k] = v[0]
            end
          end
          super({ directory: directory }.merge!(attributes))
        end
      end
    end
  end
end
