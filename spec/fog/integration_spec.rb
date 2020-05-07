# frozen_string_literal: true
require 'tempfile'
require 'spec_helper'

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

  it 'Should get all directories in bucket' do
    system("aliyun oss mkdir oss://#{@conn.aliyun_oss_bucket}/test_dir1 > /dev/null")
    system("aliyun oss mkdir oss://#{@conn.aliyun_oss_bucket}/test_dir2 > /dev/null")
    system("aliyun oss mkdir oss://#{@conn.aliyun_oss_bucket}/test_dir3 > /dev/null")
    expect(@conn.directories.all.length).to eq(3)
  end

  it 'Should get container in bucket' do
    system("aliyun oss mkdir oss://#{@conn.aliyun_oss_bucket}/test_dir > /dev/null")
    expect(@conn.get_container('').length).to eq(1)
  end

  it 'Should find test file in the root of bucket' do
    file = Tempfile.new('fog-upload-file')
    file.write("Hello World!")
    begin
      system("aliyun oss appendfromfile #{file.path} oss://#{@conn.aliyun_oss_bucket}/test_file > /dev/null")
      files = @conn.directories.get(@conn.aliyun_oss_bucket).files
      expect(files.length).to eq(1)
      expect(files.empty?).to eq(false)
      expect(files[0].key).to eq("test_file")
      expect(files.get("test_file").key).to eq("test_file")
    ensure
      file.close
      file.unlink
    end
  end

  it 'Should find 2 tests file in the root of bucket' do
    file = Tempfile.new('fog-upload-file')
    file.write("Hello World!")
    begin
      system("aliyun oss appendfromfile #{file.path} oss://#{@conn.aliyun_oss_bucket}/test_file1 > /dev/null")
      system("aliyun oss appendfromfile #{file.path} oss://#{@conn.aliyun_oss_bucket}/test_file2 > /dev/null")
      files = @conn.directories.get(@conn.aliyun_oss_bucket).files
      expect(files.length).to eq(2)
      expect(files.all.length).to eq(2)
      expect(files.empty?).to eq(false)
      expect(files[0].key).to eq("test_file1")
      expect(files[1].key).to eq("test_file2")
      expect(files.get("test_file1").key).to eq("test_file1")
      expect(files.get("test_file2").key).to eq("test_file2")
    ensure
      file.close
      file.unlink
    end
  end

  it 'Should find test directory in the root of bucket' do
    system("aliyun oss mkdir oss://#{@conn.aliyun_oss_bucket}/test_dir > /dev/null")
    bucket = @conn.directories.get(@conn.aliyun_oss_bucket)
    expect(bucket.files.length).to eq(1)
    expect(bucket.files.empty?).to eq(false)
    expect(bucket.files[0].key).to eq("test_dir/")
    expect(bucket.files.get("test_dir/").key).to eq("test_dir/")
  end

  it 'Should find no files in test directory' do
    system("aliyun oss mkdir oss://#{@conn.aliyun_oss_bucket}/test_dir > /dev/null")
    bucket = @conn.directories.get(@conn.aliyun_oss_bucket)
    dir = bucket.files.get("test_dir/").directory
    files = dir.files
    expect(files.length).to eq(1)
    expect(files[0].key).to eq("test_dir/")
  end

  it 'Should find test file inside test directory of bucket' do
    file = Tempfile.new('fog-upload-file')
    file.write("Hello World!")
    begin
      system("aliyun oss mkdir oss://#{@conn.aliyun_oss_bucket}/test_dir > /dev/null")
      system("aliyun oss appendfromfile #{file.path} oss://#{@conn.aliyun_oss_bucket}/test_dir/test_file > /dev/null")
      bucket = @conn.directories.get(@conn.aliyun_oss_bucket)
      dir = bucket.files.get("test_dir/").directory
      files = dir.files
      expect(files.empty?).to eq(false)
      # In AWS the path & key is test_dir/test_file
      expect(files.get("test_file").key).to eq("test_file")
    ensure
      file.close
      file.unlink
    end
  end

  it 'Should find 2 tests file in the directory' do
    file = Tempfile.new('fog-upload-file')
    file.write("Hello World!")
    begin
      system("aliyun oss mkdir oss://#{@conn.aliyun_oss_bucket}/test_dir > /dev/null")
      system("aliyun oss appendfromfile #{file.path} oss://#{@conn.aliyun_oss_bucket}/test_dir/test_file1 > /dev/null")
      system("aliyun oss appendfromfile #{file.path} oss://#{@conn.aliyun_oss_bucket}/test_dir/test_file2 > /dev/null")
      bucket = @conn.directories.get(@conn.aliyun_oss_bucket)
      dir = bucket.files.get("test_dir/").directory
      files = dir.files
      expect(files.empty?).to eq(false)
      # In AWS the path & key is test_dir/test_file1
      expect(files.get("test_file1").key).to eq("test_file1")
      expect(files.get("test_file2").key).to eq("test_file2")
    ensure
      file.close
      file.unlink
    end
  end

  # According to AliCloud documentation Max-keys parameter can get from 1 to 1000 value.
  # In AWS the default is standing on 1000,
  # https://github.com/fog/fog-aws/blob/daa50bb3717a462baf4d04d0e0cbfc18baacb541/lib/fog/aws/requests/storage/get_bucket.rb#L81
  it 'Should find 1000 tests file in the test directory' do
    file = Tempfile.new('fog-upload-file')
    file.write("Hello World!")
    begin
      system("aliyun oss mkdir oss://#{@conn.aliyun_oss_bucket}/test_dir > /dev/null")
      files_count=1000
      files_count.times do |n|
        system("aliyun oss appendfromfile #{file.path} oss://#{@conn.aliyun_oss_bucket}/test_dir/test_file#{n} > /dev/null")
      end
      bucket = @conn.directories.get(@conn.aliyun_oss_bucket)
      dir = bucket.files.get("test_dir/").directory
      files = dir.files
      expect(files.length).to eq(files_count)
      expect(files.empty?).to eq(false)
      # In AWS the first item is directory, so result will have directory + 999 files
      (files_count - 1).times do |n|
        # In AWS the path & key is test_dir/test_file
        expect(files.get("test_file#{n}").key).to eq("test_file#{n}")
      end
    ensure
      file.close
      file.unlink
    end
  end

  it 'Should find directory using bucket name and prefix' do
    file = Tempfile.new('fog-upload-file')
    file.write("Hello World!")
    begin
      system("aliyun oss mkdir oss://#{@conn.aliyun_oss_bucket}/test_dir > /dev/null")
      system("aliyun oss appendfromfile #{file.path} oss://#{@conn.aliyun_oss_bucket}/test_dir/test_file > /dev/null")
      bucket = @conn.directories.get(@conn.aliyun_oss_bucket, prefix: "test_dir")
      expect(bucket.files.size).to eq(2) # test dir + test file
    ensure
      file.close
      file.unlink
    end
  end

  it 'Should find directory using bucket name and prefix when bucket with the same name as directory exists' do
    file = Tempfile.new('fog-upload-file')
    file.write("Hello World!")
    begin
      dir_name=rand(36**16).to_s(36)
      system("aliyun oss mb oss://#{dir_name} > /dev/null")
      system("aliyun oss mkdir oss://#{@conn.aliyun_oss_bucket}/#{dir_name} > /dev/null")
      system("aliyun oss appendfromfile #{file.path} oss://#{@conn.aliyun_oss_bucket}/#{dir_name}/test_file > /dev/null")
      bucket = @conn.directories.get(@conn.aliyun_oss_bucket, prefix: dir_name)
      expect(bucket.files.size).to eq(2) # test dir + test file
    ensure
      file.close
      file.unlink
    end
  end

  it 'Should create a new directory' do
    bucket = @conn.directories.get(@conn.aliyun_oss_bucket)
    bucket.files.create :key => 'test_dir/'
    expect(bucket.files.get("test_dir/").key).to eq("test_dir/")
  end

  it 'Should create a new file in directory' do
    bucket = @conn.directories.get(@conn.aliyun_oss_bucket)
    bucket.files.create :key => 'test_dir/test_file'
    expect(bucket.files.get("test_dir/test_file").key).to eq("test_dir/test_file")
  end

  # Potential issue when directory in bucket matches to some already existing bucket name
#  it 'Should find directory using bucket name and prefix when bucket with the same name as directory exists without prefix' do
#    file = Tempfile.new('fog-upload-file')
#    file.write("Hello World!")
#    begin
#      dir_name=rand(36**16).to_s(36)
#      system("aliyun oss mb oss://#{dir_name} > /dev/null")
#      system("aliyun oss mkdir oss://#{@conn.aliyun_oss_bucket}/#{dir_name} > /dev/null")
#      system("aliyun oss appendfromfile #{file.path} oss://#{@conn.aliyun_oss_bucket}/#{dir_name}/test_file > /dev/null")
#      directory = @conn.directories.get(dir_name)
#      expect(directory.files.size).to eq(1) # test file
#    ensure
#      file.close
#      file.unlink
#    end
# end

end