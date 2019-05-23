module Fog
  module Compute
    class Aliyun
      class KeyPairs < Fog::Collection
        model Fog::Compute::Aliyun::KeyPair
        def all(filters_arg = {})
          unless filters_arg.is_a?(Hash)
            Fog::Logger.deprecation(" all with #{filters_arg.class} param is deprecated, use all('KeyPairName' => []) instead [light_black](#{caller.first})[/]")
            filters_arg = { name: [*filters_arg] }
          end
          data = Fog::JSON.decode(service.describe_key_pairs(filters_arg).body)['KeyPairs']['KeyPair']
          load(data)
        end

        def get(keyPairName)
          self.class.new(service: service).all(name: keyPairName)[0] if keyPairName
        end
      end
    end
  end
end
