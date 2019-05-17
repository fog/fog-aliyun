module Fog
  module Compute
    class Aliyun
      class Real
        def create_key_pair(keyPairName, options = {})
          _action = 'CreateKeyPair'
          _sigNonce = randonStr
          _time = Time.new.utc

          _parameters = defalutParameters(_action, _sigNonce, _time)
          _pathURL = defaultAliyunUri(_action, _sigNonce, _time)

          _parameters['KeyPairName'] = keyPairName
          _pathURL += '&KeyPairName=' + keyPairName

          tagNKey = options[:tag_n_key]
          tagNValue = options[:tag_n_value]

          if tagNKey
            _parameters['Tag.n.Key'] = tagNKey
            _pathURL += '&Tag.n.Key=' + tagNKey
          end

          if tagNValue
            _parameters['Tag.n.Value'] = tagNValue
            _pathURL += '&Tag.n.Value=' + tagNValue
          end

          _signature = sign(@aliyun_accesskey_secret, _parameters)
          _pathURL += '&Signature=' + _signature

          request(
            expects: [200, 203],
            method: 'GET',
            path: _pathURL
          )
        end
      end
    end
  end
end
