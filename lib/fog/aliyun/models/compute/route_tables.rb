require 'fog/core/collection'
require 'fog/aliyun/models/compute/route_table'

module Fog
  module Compute
    class Aliyun
      class RouteTables < Fog::Collection
        attribute :v_router

        model Fog::Compute::Aliyun::RouteTable


        def all(options={})
          requires :v_router
          data = Fog::JSON.decode(service.list_route_tables(v_router.id, options).body)['RouteTables']['RouteTable']
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

        def get(routeTableId)
          requires :v_router
          if routeTableId
            self.class.new(:service => service,:v_router=>v_router).all(:routeTableId=>routeTableId)[0]
          end
        end
      end
    end
  end
end
