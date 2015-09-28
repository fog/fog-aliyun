require 'fog/core/collection'
require 'fog/aliyun/models/compute/image'

module Fog
  module Compute
    class Aliyun
      class Images < Fog::Collection
        attribute :filters

        model Fog::Compute::Aliyun::Image

        attribute :server

        def initialize(attributes)
          self.filters ||= {}
          super
        end

        def all(options={})
          data = Fog::JSON.decode(service.list_images(options).body)['Images']['Image']
        end

        def get(image_id)
          data = Fog::JSON.decode(service.list_images(:imangeId=>image_id).body)['Images']['Image'][0]
        end
      end
    end
  end
end
