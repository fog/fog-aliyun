module Fog
  module Compute
    class Aliyun
      class Real
        def create_vpc(cidrBlock, options = {})
          # {Aliyun API Reference}[https://docs.aliyun.com/?spm=5176.100054.3.1.DGkmH7#/pub/ecs/open-api/vpc&createvpc]
          action = 'CreateVpc'
          sigNonce = randonStr
          time = Time.new.utc

          parameters = defalutParameters(action, sigNonce, time)
          pathUrl    = defaultAliyunUri(action, sigNonce, time)

          parameters['CidrBlock'] = cidrBlock
          pathUrl += '&CidrBlock='
          pathUrl += URI.encode(cidrBlock, '/[^!*\'()\;?:@#&%=+$,{}[]<>`" ')

          name = options[:name]
          desc = options[:description]

          if name
            parameters['VpcName'] = name
            pathUrl += '&VpcName='
            pathUrl += name
          end

          if desc
            parameters['Description'] = desc
            pathUrl += '&Description='
            pathUrl += desc
          end

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
    end # aliyun
  end # compute
end # fog
