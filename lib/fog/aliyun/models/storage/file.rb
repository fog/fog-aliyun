# frozen_string_literal: true

require 'fog/core/model'

module Fog
  module Aliyun
    class Storage
      class File < Fog::Model
        identity :key, aliases: ['Key', 'Name', 'name']

        attr_writer :body
        attribute :cache_control, aliases: 'Cache-Control'
        attribute :content_encoding, aliases: 'Content-Encoding'
        attribute :date, aliases: 'Date'
        attribute :content_length, aliases: ['Content-Length', 'Size'], type: :integer
        attribute :content_md5, aliases: 'Content-MD5'
        attribute :content_type, aliases: 'Content-Type'
        attribute :connection, aliases: 'Connection'
        attribute :content_disposition, aliases: 'Content-Disposition'
        attribute :etag, aliases: ['Etag', 'ETag']
        attribute :expires, aliases: 'Expires'
        attribute :metadata
        attribute :owner, aliases: 'Owner'
        attribute :last_modified, aliases: 'Last-Modified', type: :time
        attribute :accept_ranges, aliases: 'Accept-Ranges'
        attribute :server, aliases: 'Server'
        attribute :object_type, aliases: ['x-oss-object-type', 'x_oss_object_type']

        # @note Chunk size to use for multipart uploads.
        #     Use small chunk sizes to minimize memory. E.g. 5242880 = 5mb
        attr_reader :multipart_chunk_size
        def multipart_chunk_size=(mp_chunk_size)
          raise ArgumentError.new("minimum multipart_chunk_size is 5242880") if mp_chunk_size < 5242880
          @multipart_chunk_size = mp_chunk_size
        end

        def acl
          requires :directory, :key
          service.get_object_acl(directory.key, key)
        end

        def acl=(new_acl)
          valid_acls = ['private', 'public-read', 'public-read-write', 'default']
          unless valid_acls.include?(new_acl)
            raise ArgumentError.new("acl must be one of [#{valid_acls.join(', ')}]")
          end
          @acl = new_acl
        end

        def body
          return attributes[:body] if attributes[:body]
          return '' unless last_modified

          file = collection.get(identity)
          if file
            attributes[:body] = file.body
          else
            attributes[:body] = ''
          end
        end

        def body=(new_body)
          attributes[:body] = new_body
        end

        def directory
          @directory
        end

        # Copy object from one bucket to other bucket.
        #
        #     required attributes: directory, key
        #
        # @param target_directory_key [String]
        # @param target_file_key [String]
        # @param options [Hash] options for copy_object method
        # @return [String] Fog::Aliyun::Files#head status of directory contents
        #
        def copy(target_directory_key, target_file_key, options = {})
          requires :directory, :key
          service.copy_object(directory.key, key, target_directory_key, target_file_key, options)
          target_directory = service.directories.new(:key => target_directory_key)
          target_directory.files.head(target_file_key)
        end

        def destroy(options = {})
          requires :directory, :key
          # TODO support versionId
          # attributes[:body] = nil if options['versionId'] == version
          service.delete_object(directory.key, key, options)
          true
        end

        remove_method :metadata
        def metadata
          attributes.reject {|key, value| !(key.to_s =~ /^x-oss-/)}
        end

        remove_method :metadata=
        def metadata=(new_metadata)
          merge_attributes(new_metadata)
        end

        remove_method :owner=
        def owner=(new_owner)
          if new_owner
            attributes[:owner] = {
                :display_name => new_owner['DisplayName'] || new_owner[:display_name],
                :id           => new_owner['ID'] || new_owner[:id]
            }
          end
        end

        def public=(new_public)
          new_public
        end

        # Get a url for file.
        #
        #     required attributes: directory, key
        #
        # @param expires [String] number of seconds (since 1970-01-01 00:00) before url expires
        # @param options [Hash]
        # @return [String] url
        #
        def url(expires, options = {})

          expires = expires.nil? ? 0 : expires.to_i

          requires :directory, :key
          bucket_name, directory_key = collection.check_directory_key(directory.key)
          object = if directory_key == ''
                     key
                   else
                     directory_key + '/' + key
                   end
          service.get_object_http_url_public(object, expires, options.merge(bucket: bucket_name))
        end

        def public_url
          requires :key
          collection.get_url(key)
        end

        def save(options = {})
          requires :body, :directory, :key
          options['Content-Type'] = content_type if content_type
          options['Content-Disposition'] = content_disposition if content_disposition
          options.merge!(metadata_to_headers)
          bucket_name, directory_key = collection.check_directory_key(directory.key)
          object = if directory_key == ''
                     key
                   else
                     directory_key + '/' + key
                   end
          if body.is_a?(::File)
            service.put_object(object, body, options.merge(bucket: bucket_name))
          elsif body.is_a?(String)
            service.put_object_with_body(object, body, options.merge(bucket: bucket_name))
          else
            raise Fog::Aliyun::Storage::Error, " Forbidden: Invalid body type: #{body.class}!"
          end

          begin
            data = service.head_object(object, bucket: bucket_name)
            update_attributes_from(data)
            refresh_metadata

            self.content_length = Fog::Storage.get_body_size(body)
            self.content_type ||= Fog::Storage.get_content_type(body)
            true
          rescue Exception => error
            case error.http_code.to_i
              when 404
                nil
              else
                raise(error)
            end
          end
        end

        private

        attr_writer :directory

        def refresh_metadata
          metadata.reject! { |_k, v| v.nil? }
        end

        def headers_to_metadata
          key_map = key_mapping
          Hash[metadata_attributes.map { |k, v| [key_map[k], v] }]
        end

        def key_mapping
          key_map = metadata_attributes
          key_map.each_pair { |k, _v| key_map[k] = header_to_key(k) }
        end

        def header_to_key(opt)
          opt.gsub(metadata_prefix, '').split('-').map { |k| k[0, 1].downcase + k[1..-1] }.join('_').to_sym
        end

        def metadata_to_headers
          header_map = header_mapping
          Hash[metadata.map { |k, v| [header_map[k], v] }]
        end

        def header_mapping
          header_map = metadata.dup
          header_map.each_pair { |k, _v| header_map[k] = key_to_header(k) }
        end

        def key_to_header(key)
          metadata_prefix + key.to_s.split(/[-_]/).map(&:capitalize).join('-')
        end

        def metadata_attributes
          if last_modified
            bucket_name, directory_key = collection.check_directory_key(directory.key)
            object = if directory_key == ''
                       key
                     else
                       directory_key + '/' + key
                     end


            begin
              data = service.head_object(object, bucket: bucket_name)
              if data.code.to_i == 200
                headers = data.headers
                headers.select! { |k, _v| metadata_attribute?(k) }
              end
            rescue Exception => error
              case error.http_code.to_i
                when 404
                  {}
                else
                  raise(error)
              end
            end
          else
            {}
          end
        end

        def metadata_attribute?(key)
          key.to_s =~ /^#{metadata_prefix}/
        end

        def metadata_prefix
          'x_oss_meta_'
        end

        def update_attributes_from(data)
          merge_attributes(data.headers.reject { |key, _value| [:content_length, :content_type].include?(key) })
        end
      end
    end
  end
end
