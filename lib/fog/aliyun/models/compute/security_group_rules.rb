require 'fog/core/collection'
require 'fog/aliyun/models/compute/security_group_rule'

module Fog
  module Compute
    class Aliyun
      class SecurityGroupRules < Fog::Collection
        model Fog::Compute::Aliyun::SecurityGroupRule
        
        def get(security_group_id, options={})
          data = Fog::JSON.decode(service.list_security_group_rules(security_group_id, options).body)
        end
        
      end
    end
  end
end
