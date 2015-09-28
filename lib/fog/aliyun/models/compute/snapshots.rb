require 'fog/core/collection'
require 'fog/aliyun/models/compute/snapshot'

module Fog
  module Compute
    class Aliyun
      class Snapshots < Fog::Collection
        model Fog::Compute::Aliyun::Snapshot

        def all(options={})
          data = Fog::JSON.decode(service.list_snapshoots(options).body)['Snapshots']['Snapshot']
        end

        def get(snapshot_id)
          data = Fog::JSON.decode(service.list_snapshoots(:snapshotIds=>[snapshot_id]).body)['Snapshots']['Snapshot'][0]
        end
      end
    end
  end
end
