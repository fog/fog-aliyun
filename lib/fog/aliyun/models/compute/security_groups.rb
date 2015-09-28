require 'fog/core/collection'
require 'fog/aliyun/models/compute/security_group'

module Fog
  module Compute
    class Aliyun
      class SecurityGroups < Fog::Collection
        model Fog::Compute::Aliyun::SecurityGroup

        def all(options={})
          data = Fog::JSON.decode(service.list_security_groups(options).body)['SecurityGroups']['SecurityGroup']
          #['Images']['Image']
        end

      end
    end
  end
end
