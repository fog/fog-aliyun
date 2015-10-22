require 'fog/core/collection'
require 'fog/aliyun/models/compute/security_group_rule'

module Fog
  module Compute
    class Aliyun
      class SecurityGroupRules < Fog::Collection
        model Fog::Compute::Aliyun::SecurityGroupRule
        attribute :security_group_id

        def get(security_group_id,options={})
          data = Fog::JSON.decode(service.list_security_group_rules(security_group_id, options).body)
          self.security_group_id = data["SecurityGroupId"]
          data = data["Permissions"]["Permission"]
          load(data)
        end
        
        # def get(security_group_id, options={})
          
        # end
        
      end
    end
  end
end
