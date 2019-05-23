# frozen_string_literal: true

require 'fog/core/model'
module Fog
  module Compute
    class Aliyun
      class KeyPair < Fog::Model
        attribute :name, aliases: 'KeyPairName'
        attribute :tag_n_key, aliases: 'Tag.n.Key'
        attribute :tag_n_value, aliases: 'Tag.n.Value'
        attribute :finger_print, aliases: 'KeyPairFingerPrint'
        attribute :private_key, aliases: 'PrivateKeyBody'
        attribute :public_key, aliases: 'PublicKeyBody'
        attribute :page_number, aliases: 'PageNumber'
        attribute :page_size, aliases: 'PageSize'

        def destroy
          requires :name
          service.delete_key_pairs(name)
          true
        end

        def save(options = {})
          requires :name
          data = Fog::JSON.decode(service.create_key_pair(name, options).body)
          merge_attributes(data)
          true
        end
      end
    end
  end
end
