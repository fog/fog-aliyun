require 'fog/core/model'
require 'fog/aliyun/models/meta_parent'

module Fog
  module Compute
    class Aliyun
      class Metadatum < Fog::Model
        include Fog::Compute::Aliyun::MetaParent

        identity :key
        attribute :value

        def destroy
          requires :identity
          service.delete_meta(collection_name, @parent.id, key)
          true
        end

        def save
          requires :identity, :value
          service.update_meta(collection_name, @parent.id, key, value)
          true
        end
      end
    end
  end
end
