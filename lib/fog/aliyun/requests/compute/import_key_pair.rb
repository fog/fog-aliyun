module Fog
  module Compute
    class Aliyun
      class Real
        def import_key_pair(publicKeyBody, keyPairName)
          action = 'ImportKeyPair'
          sigNonce = randonStr
          time = Time.new.utc

          parameters = defalutParameters(action, sigNonce, time)
          pathUrl = defaultAliyunUri(action, sigNonce, time)

          parameters['KeyPairName'] = keyPairName
          pathUrl += '&KeyPairName='
          pathUrl += keyPairName

          parameters['PublicKeyBody'] = publicKeyBody
          pathUrl += '&PublicKeyBody='
          pathUrl += URI.encode(publicKeyBody, '/[^!*\'()\;?:@#&%=+$,{}[]<>`" ')

          signature = sign(@aliyun_accesskey_secret, parameters)
          pathUrl += '&Signature='
          pathUrl += signature

          request(
            expects: [200, 203],
            method: 'GET',
            path: pathUrl
          )
        end
      end
    end
  end
end
