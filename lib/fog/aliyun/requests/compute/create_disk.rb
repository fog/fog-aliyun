module Fog
  module Compute
    class Aliyun
      class Real
        def create_disk(size, options={})

          action   = 'CreateDisk'
          sigNonce = randonStr()
          time     = Time.new.utc

          parameters = defalutParameters(action, sigNonce, time)
          pathUrl    = defaultAliyunUri(action, sigNonce, time)
          
          parameters["ZoneId"] = @aliyun_zone_id
          pathUrl += '&ZoneId='
          pathUrl += @aliyun_zone_id	
          
          parameters["Size"] = size
          pathUrl += '&Size='
          pathUrl += size	

          name  = options[:name]
          desc  = options[:description]

          if name
            parameters["DiskName"] = name
            pathUrl += '&DiskName='
            pathUrl += name	
          end

          if desc
            parameters["Description"] = desc
            pathUrl += '&Description='
            pathUrl += desc	
          end

          signature = sign(@aliyun_accesskey_secret, parameters)
          pathUrl += '&Signature='
          pathUrl += signature

          request(
            :expects  => [200, 203],
            :method   => 'GET',
            :path     => pathUrl
          )
        end
        
        def create_disk_by_snapshot(snapshotId, options={})

          action   = 'CreateDisk'
          sigNonce = randonStr()
          time     = Time.new.utc

          parameters = defalutParameters(action, sigNonce, time)
          pathUrl    = defaultAliyunUri(action, sigNonce, time)
          
          parameters["ZoneId"] = @aliyun_zone_id
          pathUrl += '&ZoneId='
          pathUrl += @aliyun_zone_id  
          
          parameters["SnapshotId"] = snapshotId
          pathUrl += '&SnapshotId='
          pathUrl += snapshotId 

          name  = options[:name]
          desc  = options[:description]

          if name
            parameters["DiskName"] = name
            pathUrl += '&DiskName='
            pathUrl += name 
          end

          if desc
            parameters["Description"] = desc
            pathUrl += '&Description='
            pathUrl += desc 
          end

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
        def create_security_group(name, description)
          Fog::Identity::OpenStack.new(:openstack_auth_url => credentials[:openstack_auth_url])
          tenant_id = Fog::Identity::OpenStack::V2::Mock.data[current_tenant][:tenants].keys.first
          security_group_id = Fog::Mock.random_numbers(2).to_i + 1
          self.data[:security_groups][security_group_id.to_s] = {
            'tenant_id' => tenant_id,
            'rules'     => [],
            'id'        => security_group_id,
            'name'      => name,
            'description' => description
          }

          response = Excon::Response.new
          response.status = 200
          response.headers = {
            'X-Compute-Request-Id' => "req-#{Fog::Mock.random_hex(32)}",
            'Content-Type'   => 'application/json',
            'Content-Length' => Fog::Mock.random_numbers(3).to_s,
            'Date'           => Date.new}
          response.body = {
            'security_group' => self.data[:security_groups][security_group_id.to_s]
          }
          response
        end
      end # mock
    end # openstack
  end # compute
end # fog
