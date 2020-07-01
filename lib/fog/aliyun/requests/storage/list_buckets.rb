# frozen_string_literal: true

module Fog
  module Aliyun
    class Storage
      class Real
        def list_buckets(options = {})
          prefix = options[:prefix]
          marker = options[:marker]
          maxKeys = options[:maxKeys] || 1000
          maxKeys =[maxKeys,1000].min
          raise "max-keys must be an integer between 1 and 1000" if maxKeys<1

          path = ''
          if prefix
            path += '?prefix=' + prefix
            path += '&marker=' + marker if marker
            path += '&max-keys=' + maxKeys if maxKeys

          elsif marker
            path += '?marker=' + marker
            path += '&max-keys=' + maxKeys if maxKeys

          elsif maxKeys
            path += '?max-keys=' + maxKeys
          end

          ret = request(
            expects: [200, 203],
            method: 'GET',
            path: path
          )
          xml = ret.data[:body]
          XmlSimple.xml_in(xml)['Buckets'][0]
        end
      end
    end
  end
end
