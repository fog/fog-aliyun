module Fog
  module Compute
    class Aliyun
      class Real
        def delete_security_group_ip_rule(securitygroup_id, sourceCidrIp, nicType, option = {})
          # {Aliyun API Reference}[https://docs.aliyun.com/?spm=5176.100054.3.1.DGkmH7#/pub/ecs/open-api/securitygroup&revokesecuritygroup]
          action   = 'RevokeSecurityGroup'
          sigNonce = randonStr
          time     = Time.new.utc

          parameters = defalutParameters(action, sigNonce, time)
          pathUrl    = defaultAliyunUri(action, sigNonce, time)

          parameters['SecurityGroupId'] = securitygroup_id
          pathUrl += '&SecurityGroupId='
          pathUrl += securitygroup_id

          parameters['SourceCidrIp'] = sourceCidrIp
          pathUrl += '&SourceCidrIp='
          pathUrl += URI.encode(sourceCidrIp, '/[^!*\'()\;?:@#&%=+$,{}[]<>`" ')
          nicType = 'intranet' unless nicType
          parameters['NicType'] = nicType
          pathUrl += '&NicType='
          pathUrl += nicType

          portRange = option[:portRange]
          portRange = '-1/-1' unless portRange
          parameters['PortRange'] = portRange
          pathUrl += '&PortRange='
          pathUrl += URI.encode(portRange, '/[^!*\'()\;?:@#&%=+$,{}[]<>`" ')

          protocol = option[:protocol]
          protocol = 'all' unless protocol
          parameters['IpProtocol'] = protocol
          pathUrl += '&IpProtocol='
          pathUrl += protocol

          policy = option[:policy]
          policy = 'accept' unless policy
          parameters['Policy'] = policy
          pathUrl += '&Policy='
          pathUrl += policy

          priority = option[:priority]
          priority = '1' unless priority
          parameters['Priority'] = priority
          pathUrl += '&Priority='
          pathUrl += priority

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
