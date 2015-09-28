require 'fog/core/collection'
require 'fog/aliyun/models/compute/vpc'

module Fog
  module Compute
    class Aliyun
      class Vpcs < Fog::Collection
        attribute :filters

        model Fog::Compute::Aliyun::VPC

        # Creates a new VPC
        #
        # Aliyun.vpcs.new
        #
        # ==== Returns
        #
        # Returns the details of the new VPC
        #
        #>> Aliyun.vpcs.new
        # <Fog::Aliyun::VPC::VPC
        # id=nil,
        # state=nil,
        # cidr_block=nil,
        # dhcp_options_id=nil
        # tags=nil
        # tenancy=nil
        # >
        #

        def initialize(attributes)
          self.filters ||= {}
          super
        end

        # Returns an array of all VPCs that have been created
        #
        # Aliyun.vpcs.all
        #
        # ==== Returns
        #
        # Returns an array of all VPCs
        #
        #>> Aliyun.vpcs.all
        # <Fog::Aliyun::VPC::VPCs
        # filters={}
        # [
        # <Fog::Aliyun::VPC::VPC
        # id="vpc-12345678",
        # TODO
        # >
        # ]
        # >
        #

        def all(filters_arg = filters)
          unless filters_arg.is_a?(Hash)
            Fog::Logger.warning("all with #{filters_arg.class} param is deprecated, use all('vpcId' => []) instead [light_black](#{caller.first})[/]")
            filters_arg = {'vpcId' => [*filters_arg]}
          end
          filters = filters_arg
          data = Fog::JSON.decode(service.list_vpcs(filters).body)['Vpcs']['Vpc']
          load(data)
        end

        # Used to retrieve a VPC
        # vpc_id is required to get the associated VPC information.
        #
        # You can run the following command to get the details:
        # Aliyun.vpcs.get("vpc-12345678")
        #
        # ==== Returns
        #
        #>> Aliyun.vpcs.get("vpc-12345678")
        # <Fog::Aliyun::Compute::VPC
        # id="vpc-12345678",
        # TODO
        # >
        #

        def get(vpcId)
          if vpcId
            $vpc=self.class.new(:service => service).all('vpcId' => vpcId)[0]
          end
        end
      end
    end
  end
end
