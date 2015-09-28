require 'fog/core/model'
module Fog
  module Compute
    class Aliyun
      class VPC < Fog::Model
        identity  :id,               :aliases => 'VpcId'
        attribute :vpc_name,         :aliases => 'VpcName'
        attribute :state,            :aliases => 'Status'
        attribute :cidr_block,       :aliases => 'CidrBlock'
        attribute :v_switch_ids,     :aliases => 'VSwitchIds'
        attribute :description,      :aliases => 'Description'
        attribute :user_cidrs,       :aliases => 'UserCidrs'
        attribute :region_id,        :aliases => 'RegionId'
        attribute :v_router_id,      :aliases => 'VRouterId'
        attribute :creation_time,    :aliases => 'CreationTime'
        # def initialize(attributes={})
        #   self.dhcp_options_id ||= "default"
        #   self.tenancy ||= "default"
        #   super
        # end

        def ready?
          requires :state
          state == 'Available'
        end

        # Removes an existing vpc
        #
        # vpc.destroy
        #
        # ==== Returns
        #
        # True or false depending on the result
        #

        def destroy
          requires :id

          service.delete_vpc(id)
          true
        end

        def vswitches
          @vswitches ||= begin
            Fog::Compute::Aliyun::Vswitches.new(
              :vpc     => self,
              :service => service
            )
          end
        end

        # Create a vpc
        #
        # >> g = Aliyun.vpcs.new(:cidr_block => "10.1.2.0/24")
        # >> g.save
        #
        # == Returns:
        #
        # True or an exception depending on the result. Keep in mind that this *creates* a new vpc.
        # As such, it yields an InvalidGroup.Duplicate exception if you attempt to save an existing vpc.
        #

        def save(options={})
          requires :cidr_block
          options[:name]=vpc_name if vpc_name
          options[:description]=description if description
          data = Fog::JSON.decode(service.create_vpc(cidr_block,options).body)
          # new_attributes = data.reject {|key,value| key == 'RequestId'}
          # new_attributes = data.reject {|key,value| key == 'RequestId' || key == 'RouteTableId' }
          # merge_attributes(new_attributes)
          true
        end
      end
    end
  end
end
