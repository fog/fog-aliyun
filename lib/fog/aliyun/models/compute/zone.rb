require 'fog/core/model'
module Fog
  module Compute
    class Aliyun
      class Zone < Fog::Model
        attribute :zone_id, aliases: 'ZoneId'
        attribute :dedicated_host_types, aliases: 'AvailableDedicatedHostTypes'
        attribute :disk_categories, aliases: 'AvailableDiskCategories'
        attribute :instance_types, aliases: 'AvailableInstanceTypes'
        attribute :resource_creation, aliases: 'AvailableResourceCreation'
        attribute :resources, aliases: 'AvailableResources'
        attribute :data_disk_categories, aliases: 'DataDiskCategories'
        attribute :instance_generations, aliases: 'InstanceGenerations'
        attribute :instance_type_families, aliases: 'InstanceTypeFamilies'
        attribute :instance_types, aliases: 'InstanceTypes'
        attribute :io_optimized, aliases: 'IoOptimized'
        attribute :network_type, aliases: 'NetworkTypes'
        attribute :system_disk_categories, aliases: 'SystemDiskCategories'
        attribute :volume_categories, aliases: 'AvailableVolumeCategories'
        attribute :dedicated_host_generations, aliases: 'DedicatedHostGenerations'
        attribute :local_name, aliases: 'LocalName'
      end
    end
  end
end
