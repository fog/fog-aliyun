require 'fog/core/model'

module Fog
  module Compute
    class Aliyun
      class SecurityGroupRule < Fog::Model

        attribute :security_group_id,         :aliases => 'SecurityGroupId'
        attribute :source_cidr_ip,            :aliases => 'SourceCidrIp'
        attribute :source_owner,              :aliases => 'SourceGroupOwnerAccount'
        attribute :source_group_id,           :aliases => 'SourceGroupId'
        attribute :ip_protocol,               :aliases => 'IpProtocol'
        attribute :dest_cidr_ip,              :aliases => 'DestCidrIp'
        attribute :dest_owner,                :aliases => 'DestGroupOwnerAccount'
        attribute :dest_group_id,             :aliases => 'DestGroupId'
        attribute :nic_type,                  :aliases => 'NicType'
        attribute :policy,                    :aliases => 'Policy'
        attribute :port_range,                :aliases => 'PortRange'
        attribute :direction,                 :aliases => 'Direction'
        attribute :priority,                  :aliases => 'Priority'

        # def save
        #     requires :security_group_id,:ip_protocol,:port_range,:direction

        #     if direction=="egress"
        #         if dest_cidr_ip
        #             service.create_security_group_egress_ip_rule(id,cidr_ip,nic_type,options)
        #         elsif dest_group_id
        #             service.create_security_group_egress_sg_rule(id,dest_group_id,options)
        #         end
                    

        #     else

        #     end
        # end

        # def save
        #   requires :ip_protocol, :direction, :to_port, :parent_group_id
        #   cidr = ip_range && ip_range["cidr"]
        #   if rule = service.create_security_group_rule(parent_group_id, ip_protocol, from_port, to_port, cidr, group).data[:body]
        #     merge_attributes(rule["security_group_rule"])
        #   end
        # end

        # def destroy
        #   requires :id
        #   service.delete_security_group_rule(id)
        #   true
        # end

        # def authorize_security_group

        # end
      end
    end
  end
end
