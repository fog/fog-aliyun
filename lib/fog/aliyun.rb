# frozen_string_literal: true

require 'fog/core'
require 'fog/json'
require 'fog/aliyun/version'

module Fog
  module Compute
    autoload :Aliyun, 'fog/aliyun/compute'
  end

  module Storage
    autoload :Aliyun, 'fog/aliyun/storage'
  end

  module Aliyun
    extend Fog::Provider
    service(:compute, 'Compute')
    service(:storage, 'Storage')
  end
end
