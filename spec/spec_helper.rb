# frozen_string_literal: true

if ENV['COVERAGE']
  require 'simplecov'
  SimpleCov.start do
    add_filter 'test'
  end
end

if !ENV['INTEGRATION']
  RSpec.configure do |c|
    c.filter_run_excluding :integration => true
  end
end

if !ENV['PERFORMANCE']
  RSpec.configure do |c|
    c.filter_run_excluding :performance => true
  end
end

if !ENV['BLOBSTORE']
  RSpec.configure do |c|
    c.filter_run_excluding :blobstore => true
  end
end

$LOAD_PATH.unshift File.expand_path('../../lib', __FILE__)
require 'fog/aliyun'