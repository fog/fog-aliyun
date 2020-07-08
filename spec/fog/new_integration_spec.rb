# frozen_string_literal: true
require 'tempfile'
require 'spec_helper'

DIRECTORY_TEST_PREFIX='fog-aliyun-integration-'
describe 'Integration tests', :integration => true do

  before(:all) do
    @conn = Fog::Storage[:aliyun]
    Fog::Logger.debug('Initializing Aliyun CLI for integration test population...')
    system("aliyun configure set --language en --region #{@conn.aliyun_region_id} --access-key-id #{@conn.aliyun_accesskey_id} --access-key-secret #{@conn.aliyun_accesskey_secret}")
  end

  before(:each) do
    Fog::Logger.debug("Initializing oss bucket for tests: #{@conn.aliyun_oss_bucket}")
    system("aliyun oss rm --bucket oss://#{@conn.aliyun_oss_bucket} -r -f > /dev/null || exit 0")
    system("aliyun oss mb oss://#{@conn.aliyun_oss_bucket} > /dev/null")
  end

  it 'Should get all of directories' do
    # nested directories
    directories = @conn.directories.all
    expect(directories.length).to be > 0
  end

  it 'Should get directory and its files' do
    # nested directories
    system("aliyun oss mkdir oss://#{@conn.aliyun_oss_bucket}/test_dir/dir1/dir2/dir3 > /dev/null")
    system("aliyun oss mkdir oss://#{@conn.aliyun_oss_bucket}/test_dir2/dir1 > /dev/null")
    directory = @conn.directories.get(@conn.aliyun_oss_bucket)
    # TODO checking other attributes of directory
    expect(directory.key).to eq(@conn.aliyun_oss_bucket)
    expect(directory.location).to eq('oss-' + @conn.aliyun_region_id)
    # TODO checking other methods of directory
    files = directory.files
    expect(files.length).to eq(2)
    # TODO test directories.get options, like prefix, max-keys and so on
  end

  it 'Should create a new directory' do
    new_directory = DIRECTORY_TEST_PREFIX + 'create-' + rand(100).to_s
    @conn.directories.create :key => new_directory
    # TODO support parameter :location : @conn.directories.create :key => new_directory, :location => "oss-eu-central-1"
    directory = @conn.directories.get(new_directory)
    expect(directory.key).to eq(new_directory)
    # TODO checking other attributes of directory
    expect(directory.location).to eq('oss-' + @conn.aliyun_region_id)
    # TODO checking other methods of directory
    files = directory.files
    expect(files.length).to eq(0)
    directory.destroy!
    directory = @conn.directories.get(new_directory)
    expect(directory).to eq(nil)
  end

  it 'Should delete directory' do
    new_directory = @conn.aliyun_oss_bucket + '-delete'
    system("aliyun oss mb oss://#{new_directory} > /dev/null")
    directory = @conn.directories.get(new_directory)
    expect(directory.key).to eq(new_directory)
    # TODO checking other attributes of directory
    files = directory.files
    expect(files.length).to eq(0)
    directory.destroy
    directory = @conn.directories.get(new_directory)
    expect(directory).to eq(nil)
  end

  it 'Should delete! directory' do
    new_directory = @conn.aliyun_oss_bucket + '-delete-2'
    system("aliyun oss mb oss://#{new_directory} > /dev/null")
    system("aliyun oss mkdir oss://#{new_directory}/test_dir/dir1/dir2/dir3 > /dev/null")
    system("aliyun oss mkdir oss://#{new_directory}/test_dir2/dir1 > /dev/null")
    directory = @conn.directories.get(new_directory)
    expect(directory.key).to eq(new_directory)
    # TODO checking other attributes of directory
    files = directory.files
    expect(files.length).to eq(2)
    directory.destroy!
    directory = @conn.directories.get(new_directory)
    expect(directory).to eq(nil)
  end
end