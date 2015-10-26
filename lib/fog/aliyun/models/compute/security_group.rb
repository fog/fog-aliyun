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

        def authorize_seurity_group_sg_rule(group_id,direction="ingress",options={})
            requires :id
            if direction=="egress"
                service.create_security_group_egress_sg_rule(id,group_id,options)
            else
                service.create_security_group_sg_rule(id,group_id,options)
            end
                    
            true
        end

        def authorize_security_group_ip_rule(cidr_ip,direction="ingress",options={})
            requires :id
            nic_type=options[:nic_type]
            unless nic_type
                nic_type="internet"
            end

            if direction=="egress"
                service.create_security_group_egress_ip_rule(id,cidr_ip,nic_type,options)
            else
                service.create_security_group_ip_rule(id,cidr_ip,nic_type,options)
            end
                    
            true
        end

        def revoke_seurity_group_sg_rule(group_id,direction="ingress",options={})
            requires :id
            if direction=="egress"
                service.delete_security_group_egress_sg_rule(id,group_id,options)
            else
                service.delete_security_group_sg_rule(id,group_id,options)
            end
                    
            true
        end

        def revoke_security_group_ip_rule(cidr_ip,direction="ingress",options={})
            requires :id
            nic_type=options[:nic_type]
            unless nic_type
                nic_type="internet"
            end

            if direction=="egress"
                service.delete_security_group_egress_ip_rule(id,cidr_ip,nic_type,options)
            else
                service.delete_security_group_ip_rule(id,cidr_ip,nic_type,options)
            end
                    
            true
        end

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
