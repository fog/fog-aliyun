module Fog
  module Compute
    class Aliyun
      class Zones < Fog::Collection
        model Fog::Compute::Aliyun::Zone

        def all
          data = Fog::JSON.decode(service.list_zones.body)['Zones']['Zone']
          load(data)
        end
      end
    end
  end
end
