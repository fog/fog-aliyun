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

  it 'Should get all of files: test files.all' do
    directory_key = @conn.aliyun_oss_bucket
    file = Tempfile.new('fog-upload-file')
    file.write("Hello World!")
    begin
      system("aliyun oss mb oss://#{directory_key} > /dev/null")
      system("aliyun oss mkdir oss://#{directory_key}/test_dir1 > /dev/null")
      system("aliyun oss cp #{file.path} oss://#{directory_key}/test_dir1/test_file1 > /dev/null")
      system("aliyun oss mkdir oss://#{directory_key}/test_dir2 > /dev/null")
      system("aliyun oss cp #{file.path} oss://#{directory_key}/test_dir2/test_file2 > /dev/null")
      system("aliyun oss cp #{file.path} oss://#{directory_key}/test_file3 > /dev/null")
      files = @conn.directories.get(directory_key).files
      expect(files.length).to eq(5)
      expect(files.all.length).to eq(5)
      # TODO support more filter, like delimiter，marker，prefix, max-keys
    ensure
      file.close
      file.unlink
    end
  end

  it 'Should iteration all files: test files.each' do
    directory_key = @conn.aliyun_oss_bucket
    file = Tempfile.new('fog-upload-file')
    file.write("Hello World!")
    begin
      system("aliyun oss mb oss://#{directory_key} > /dev/null")
      system("aliyun oss mkdir oss://#{directory_key}/test_dir1 > /dev/null")
      system("aliyun oss cp #{file.path} oss://#{directory_key}/test_dir1/test_file1 > /dev/null")
      system("aliyun oss mkdir oss://#{directory_key}/test_dir2 > /dev/null")
      system("aliyun oss cp #{file.path} oss://#{directory_key}/test_dir2/test_file2 > /dev/null")
      system("aliyun oss cp #{file.path} oss://#{directory_key}/test_file3 > /dev/null")
      files = @conn.directories.get(directory_key).files
      puts files.each
      # TODO test block
    ensure
      file.close
      file.unlink
    end
  end

  it 'Should get the specified file: test files.get' do
    directory_key = @conn.aliyun_oss_bucket
    file = Tempfile.new('fog-upload-file')
    file.write("Hello World!")
    begin
      system("aliyun oss mb oss://#{directory_key} > /dev/null")
      system("aliyun oss mkdir oss://#{directory_key}/test_dir1 > /dev/null")
      system("aliyun oss cp #{file.path} oss://#{directory_key}/test_dir1/test_file1 > /dev/null")
      system("aliyun oss mkdir oss://#{directory_key}/test_dir2 > /dev/null")
      system("aliyun oss cp #{file.path} oss://#{directory_key}/test_dir2/test_file2 > /dev/null")
      system("aliyun oss cp #{file.path} oss://#{directory_key}/test_file3 > /dev/null")
      files = @conn.directories.get(directory_key).files
      get_file = files.get("test_file3")
      expect(get_file.key).to eq("test_file3")
      # TODO checking all of file attributes and more files
    ensure
      file.close
      file.unlink
    end
  end

  it 'Should head the specified file: test files.head' do
    directory_key = @conn.aliyun_oss_bucket
    file = Tempfile.new('fog-upload-file')
    file.write("Hello World!")
    begin
      system("aliyun oss mb oss://#{directory_key} > /dev/null")
      system("aliyun oss mkdir oss://#{directory_key}/test_dir1 > /dev/null")
      system("aliyun oss cp #{file.path} oss://#{directory_key}/test_dir1/test_file1 > /dev/null")
      system("aliyun oss mkdir oss://#{directory_key}/test_dir2 > /dev/null")
      system("aliyun oss cp #{file.path} oss://#{directory_key}/test_dir2/test_file2 > /dev/null")
      system("aliyun oss cp #{file.path} oss://#{directory_key}/test_file3 > /dev/null")
      files = @conn.directories.get(directory_key).files
      head_file = files.head("test_file3")
      expect(head_file.key).to eq("test_file3")
        # TODO checking all of file attributes and more files
    ensure
      file.close
      file.unlink
    end
  end
end