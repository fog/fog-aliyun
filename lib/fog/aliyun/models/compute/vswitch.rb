require 'fog/core/model'
module Fog
  module Compute
    class Aliyun
      class Vswitch < Fog::Model
        identity  :id,                  :aliases => 'VSwitchId'
        attribute :vpc_id,              :aliases => 'VpcId'
        attribute :zone_id,             :aliases => 'ZoneId'
        attribute :name,                :aliases => 'VSwitchName'
        attribute :available_ip_count,  :aliases => 'AvailableIpAddressCount'
        attribute :state,               :aliases => 'Status'
        attribute :cidr_block,          :aliases => 'CidrBlock'
        attribute :description,      :aliases => 'Description'
        attribute :region_id,        :aliases => 'RegionId'
        attribute :creation_time,    :aliases => 'CreationTime'
        def initialize(attributes={})
          super
        #   self.dhcp_options_id ||= "default"
        #   self.tenancy ||= "default"
        #   super{"CreationTime"=>"2015-08-10T03:45:40Z", "CidrBlock"=>"172.16.0.0/24", "Status"=>"Available", "Description"=>"",
        # "AvailableIpAddressCount"=>252, "VSwitchName"=>"CF_bck", "ZoneId"=>"cn-beijing-a", "VSwitchId"=>"vsw-25lws9k8e", "VpcId"=>"vpc-25mj6mguq"}
        end

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

          service.delete_vswitch(id)
          true
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
          requires :vpc,:cidr_block
          # options[:name]=name if name
          # options[:description]=description if description
          data = Fog::JSON.decode(service.create_vswitch(vpc.id, cidr_block,options).body)
          # new_attributes = data.reject {|key,value| key == 'RequestId'}
          # new_attributes = data.reject {|key,value| key == 'RequestId' || key == 'RouteTableId' }
          # merge_attributes(new_attributes)
          true
        end

        def vpc
          $vpc
        end
        
        def all()
          data = Fog::JSON.decode(service.list_vswitchs(vpc_id).body)['VSwitches']['VSwitch']
        end

      end
    end
  end
end
