module Fog
  module Compute
    class Aliyun
      class Real
        require 'json'
        def delete_key_pairs(keyPairNames)
          _action = 'DeleteKeyPairs'
          _sigNonce = randonStr
          _time = Time.new.utc

          _parameters = defalutParameters(_action, _sigNonce, _time)
          _pathURL = defaultAliyunUri(_action, _sigNonce, _time)

          # Have to modify the string manually as DeleteKeyPairs accepts KeyPairNames
          # in string type but it should be formatted as array
          keyPairNames = "['" + keyPairNames + "']"

          _parameters['KeyPairNames'] = keyPairNames
          _pathURL += '&KeyPairNames=' + keyPairNames

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
