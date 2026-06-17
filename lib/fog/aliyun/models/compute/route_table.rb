# frozen_string_literal: true

require 'fog/core/model'
module Fog
  module Aliyun
    class Compute
      class RouteTable < Fog::Model
        # "RouteTables"=>{"RouteTable"=>[
        # {"CreationTime"=>"2015-08-03T11:23:35Z", "RouteEntrys"=>{"RouteEntry"=>[
        #   {"Status"=>"Available", "Type"=>"System", "InstanceId"=>"", "RouteTableId"=>"vtb-2504onoxh", "DestinationCidrBlock"=>"172.16.0.0/24"},
        #   {"Status"=>"Available", "Type"=>"System", "InstanceId"=>"", "RouteTableId"=>"vtb-2504onoxh", "DestinationCidrBlock"=>"172.16.1.0/24"},
        #   {"Status"=>"Available", "Type"=>"System", "InstanceId"=>"", "RouteTableId"=>"vtb-2504onoxh", "DestinationCidrBlock"=>"172.16.2.0/24"},
        #   {"Status"=>"Available", "Type"=>"System", "InstanceId"=>"", "RouteTableId"=>"vtb-2504onoxh", "DestinationCidrBlock"=>"100.64.0.0/10"},
        #   {"Status"=>"Available", "Type"=>"System", "InstanceId"=>"", "RouteTableId"=>"vtb-2504onoxh", "DestinationCidrBlock"=>"10.0.0.0/8"}]},
        #  "RouteTableId"=>"vtb-2504onoxh", "RouteTableType"=>"System", "VRouterId"=>"vrt-25azmd2wm"}]}
        identity :id, aliases: 'RouteTableId'
        attribute :created_at, aliases: 'CreationTime'
        attribute :type, aliases: 'RouteTableType'
        attribute :v_router_id, aliases: 'VRouterId'
        # collection Fog::Aliyun::Compute::RouteEntrys
        def route_entrys
          @route_entrys ||= begin
            Fog::Aliyun::Compute::RouteEntrys.new(
              route_table: self,
              service: service
            )
          end
        end
      end
    end
  end
end
