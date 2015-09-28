require 'fog/core/collection'
require 'fog/aliyun/models/compute/network'

module Fog
  module Compute
    class Aliyun
      class Networks < Fog::Collection
        model Fog::Compute::Aliyun::Network

        attribute :server

        def all(options={})
          data = Fog::JSON.decode(service.list_vpcs(options).body)['Vpcs']['Vpc']
        end
      end # class Networks
    end # class OpenStack
  end # module Compute
end # module Fog
