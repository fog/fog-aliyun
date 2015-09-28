require 'fog/core/collection'
require 'fog/aliyun/models/compute/server'

module Fog
  module Compute
    class Aliyun
      class Servers < Fog::Collection
        attribute :filters

        model Fog::Compute::Aliyun::Server

        def initialize(attributes)
          self.filters ||= {}
          super
        end

        def all(options = {})
          data = Fog::JSON.decode(service.list_servers(options).body)['Instances']['Instance']
        end

        # Creates a new server and populates ssh keys
        # @return [Fog::Compute::OpenStack::Server]
        # @raise [Fog::Compute::OpenStack::NotFound] - HTTP 404
        # @raise [Fog::Compute::OpenStack::BadRequest] - HTTP 400
        # @raise [Fog::Compute::OpenStack::InternalServerError] - HTTP 500
        # @raise [Fog::Compute::OpenStack::ServiceError]
        # @example
        #   service.servers.bootstrap :name => 'bootstrap-server',
        #                             :flavor_ref => service.flavors.first.id,
        #                             :image_ref => service.images.find {|img| img.name =~ /Ubuntu/}.id,
        #                             :public_key_path => '~/.ssh/fog_rsa.pub',
        #                             :private_key_path => '~/.ssh/fog_rsa'
        #
#        def bootstrap(new_attributes = {})
#          server = create(new_attributes)
#          server.wait_for { ready? }
#          server.setup(:password => server.password)
#          server
#        end

        def get(server_id)
          server = Fog::JSON.decode(service.list_servers(:aliyun_InstanceId=>server_id).body)['Instances']['Instance'][0]
        end
      end
    end
  end
end
