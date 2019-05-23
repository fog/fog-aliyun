module Fog
  module Compute
    class Aliyun
      class Real
        def describe_key_pairs(options = {})
          _action = 'DescribeKeyPairs'
          _sigNonce = randonStr
          _time = Time.new.utc

          _parameters = defalutParameters(_action, _sigNonce, _time)
          _pathURL = defaultAliyunUri(_action, _sigNonce, _time)

          keyPairName = options[:name]
          keyPairFingerPrint = options[:fingerprint]
          pageNumber = options[:page_number]
          pageSize = options[:page_size]
          tagNKey = options[:tag_n_key]
          tagNValue = options[:tag_n_value]

          if keyPairName
            _parameters['KeyPairName'] = keyPairName
            _pathURL += '&KeyPairName=' + keyPairName
          end

          if keyPairFingerPrint
            _parameters['KeyPairFingerPrint'] = keyPairFingerPrint
            _pathURL += '&KeyPairFingerPrint=' + keyPairFingerPrint
          end

          if pageNumber
            _parameters['PageNumber'] = pageNumber
            _pathURL += '&PageNumber=' + pageNumber
          end

          if pageSize
            _parameters['PageSize'] = pageSize
            _pathURL += '&PageSize=' + pageSize
          end

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
