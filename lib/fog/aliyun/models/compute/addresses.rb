require 'fog/core/collection'
require 'fog/aliyun/models/compute/address'

module Fog
  module Compute
    class Aliyun
      class Addresses < Fog::Collection
        model Fog::Compute::Aliyun::Address

        def all(options={})
          data = Fog::JSON.decode(service.list_eip_addresses(options).body)['EipAddresses']['EipAddress']
        end

        def get(eipAddress)
          data = Fog::JSON.decode(service.list_eip_addresses(:aliyun_EipAddress=>eipAddress).body)['EipAddresses']['EipAddress']
        end

      end
    end
  end
end
