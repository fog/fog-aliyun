# frozen_string_literal: true

module Fog
  module Storage
    class Aliyun
      class Real
        def list_buckets(options = {})
          prefix = options[:prefix]
          marker = options[:marker]
          maxKeys = options[:maxKeys]

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
