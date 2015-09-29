module Fog
  module Compute
    class Aliyun
      class Real
        # {Aliyun API Reference}[https://docs.aliyun.com/?spm=5176.100054.3.1.DGkmH7#/pub/ecs/open-api/disk&describedisks]
        def list_disks(options={})
          action = 'DescribeDisks'
          sigNonce = randonStr()
          time = Time.new.utc

          parameters = defalutParameters(action, sigNonce, time)
          pathUrl    = defaultAliyunUri(action, sigNonce, time)

          pageNumber = options[:pageNumber]
          pageSize   = options[:pageSize]
          instanceId = options[:instanceId]
          diskIds = options[:diskIds]

          if instanceId
            parameters["InstanceId"] = instanceId
            pathUrl += '&InstanceId='
            pathUrl += instanceId
          end

          if diskIds
            parameters["DiskIds"] = Fog::JSON.encode(diskIds)
            pathUrl += '&DiskIds='
            pathUrl += Fog::JSON.encode(diskIds)
          end
          
          if pageNumber
            parameters["PageNumber"] = pageNumber
            pathUrl += '&PageNumber='
            pathUrl += pageNumber
          end

          pageSize   = options[:pageSize]
          unless pageSize
            pageSize = '50'   #缺省每页显示50条
          end
          parameters["PageSize"] = pageSize  
          pathUrl += '&PageSize='
          pathUrl += pageSize	

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

      class Mock
        def list_zones(*args)
          Excon::Response.new(
            :body   => { "availabilityZoneInfo" => [
                  {
                      "zoneState" => {
                          "available" => true
                      },
                      "hosts" => nil,
                      "zoneName" => "nova"
                  }
              ] },
            :status => 200
          )
        end
      end
    end
  end
end
