require 'fog/core/collection'
require 'fog/aliyun/models/storage/directory'

module Fog
  module Storage
    class Alilyun
      class Directories < Fog::Collection
        model Fog::Storage::Alilyun::Directory

        def all
          containers = service.get_containers()
          data = Array.new
          i = 0
          containers.each do |entry|
            key = entry["Prefix"][0]
            key[-1] = ''
            data[i] = {:key=>key}
            i = i + 1
          end

          load(data)
        end

        def get(key, options = {})
          if key != nil && key != "" && key != '.'
            dir = key+'/'
            ret = service.head_object(dir, options)
            if ret.data[:status] == 200
              new(:key => key)
            else
              nil
            end
          else
            ret = service.get_container("")
            if ret
              new(:key => "")
            end
          end
        rescue Fog::Storage::Alilyun::NotFound
          nil
        end
      end
    end
  end
end
