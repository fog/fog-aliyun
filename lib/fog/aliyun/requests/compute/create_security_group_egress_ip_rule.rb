module Fog
  module Compute
    class Aliyun
      class Real
        # {Aliyun API Reference}[https://docs.aliyun.com/?spm=5176.100054.3.1.DGkmH7#/pub/ecs/open-api/securitygroup&authorizesecuritygroup]
        def create_security_group_egress_ip_rule(securitygroup_id,destCidrIp, nicType, option={})

          action   = 'AuthorizeSecurityGroupEgress'
          sigNonce = randonStr()
          time     = Time.new.utc

          parameters = defalutParameters(action, sigNonce, time)
          pathUrl    = defaultAliyunUri(action, sigNonce, time)
          
          parameters["SecurityGroupId"] = securitygroup_id
          pathUrl += '&SecurityGroupId='
          pathUrl += securitygroup_id

          parameters["DestCidrIp"] = destCidrIp
          pathUrl += '&DestCidrIp='
          pathUrl += URI.encode(destCidrIp,'/[^!*\'()\;?:@#&%=+$,{}[]<>`" ')	
          unless nicType
            nicType='intranet'
          end
          parameters["NicType"] = nicType
          pathUrl += '&NicType='
          pathUrl += nicType
          
          portRange = option[:portRange]
          unless portRange
            portRange = '-1/-1'
          end
          parameters["PortRange"] = portRange
          pathUrl += '&PortRange='
          pathUrl += URI.encode(portRange,'/[^!*\'()\;?:@#&%=+$,{}[]<>`" ')
          
          protocol = option[:protocol]
          unless protocol
            protocol = 'all'
          end
          parameters["IpProtocol"] = protocol
          pathUrl += '&IpProtocol='
          pathUrl += protocol

          policy = option[:policy]
          unless policy
            policy = 'accept'
          end
          parameters["Policy"] = policy
          pathUrl += '&Policy='
          pathUrl += policy

          priority = option[:priority]
          unless priority
            priority = '1'
          end
          parameters["Priority"] = priority
          pathUrl += '&Priority='
          pathUrl += priority

          signature = sign(@aliyun_accesskey_secret, parameters)
          pathUrl += '&Signature='
          pathUrl += signature

          request(
            :expects  => [200, 203],
            :method   => 'GET',
            :path     => pathUrl
          )
        end
      end

    end # aliyun
  end # compute
end # fog
