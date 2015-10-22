require 'fog/core/model'

module Fog
  module Compute
    class Aliyun
      class SecurityGroup < Fog::Model
        # {"SecurityGroup"=>[{"CreationTime"=>"2015-08-10T03:21:02Z", 
        #   "SecurityGroupId"=>"sg-25mexinlu", "Description"=>"", "SecurityGroupName"=>"bosh", 
        #   "VpcId"=>"vpc-25mj6mguq"}}

        identity  :id,                    :aliases =>"SecurityGroupId"

        attribute :name,                  :aliases => "SecurityGroupName"
        attribute :description,           :aliases => "Description"
        attribute :created_at,            :aliases => "CreationTime"
        attribute :vpc_id,                :aliases => "VpcId"

        def vpc
            requires :vpc_id
            $vpc=Fog::Compute::Aliyun::Vpcs.new(:service=>service).all('vpcId'=>vpc_id)[0]
        end

        def security_group_rules
            requires :id
            Fog::Compute::Aliyun::SecurityGroupRules.new(:service=>service).get(id)
        end

        def save(options={})
            options[:vpcId] = vpc_id if vpc_id
            options[:name] = name if name
            options[:description] = description if description
            data = Fog::JSON.decode(service.create_security_group(options).body)
            true
        end


        def destroy
            requires :id
            service.delete_security_group(id)
            true
        end

        # def security_group_rules
        #   Fog::Compute::OpenStack::SecurityGroupRules.new(:service => service).load(attributes[:security_group_rules])
        # end

        # def rules
        #   Fog::Logger.deprecation('#rules is deprecated. Use #security_group_rules instead')
        #   attributes[:security_group_rules]
        # end

        # # no one should be calling this because it doesn't do anything
        # # useful but we deprecated the rules attribute and need to maintain the API
        # def rules=(new_rules)
        #   Fog::Logger.deprecation('#rules= is deprecated. Use the Fog::Compute::Openstack::SecurityGroupRules collection to create new rules.')
        #   attributes[:security_group_rules] = new_rules
        # end

        # def save
        #   requires :name, :description
        #   data = service.create_security_group(name, description)
        #   merge_attributes(data.body['security_group'])
        #   true
        # end

        # def destroy
        #   requires :id
        #   service.delete_security_group(id)
        #   true
        # end

        # def create_security_group_rule(min, max, ip_protocol = "tcp", cidr = "0.0.0.0/0", group_id = nil)
        #   Fog::Logger.deprecation('#create_security_group_rule is deprecated. Use the Fog::Compute::Openstack::SecurityGroupRules collection to create new rules.')
        #   requires :id
        #   service.create_security_group_rule(id, ip_protocol, min, max, cidr, group_id)
        # end

        # def delete_security_group_rule(rule_id)
        #   Fog::Logger.deprecation('#create_security_group_rule is deprecated. Use the Fog::Compute::Openstack::SecurityGroupRule objects to destroy rules.')
        #   service.delete_security_group_rule(rule_id)
        #   true
        # end
      end
    end
  end
end
