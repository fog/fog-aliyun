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

  it 'Should get nested directories and files in nested directory' do
    # nested directories
    system("aliyun oss mkdir oss://#{@conn.aliyun_oss_bucket}/test_dir/dir1/dir2/dir3 > /dev/null")
    directory = @conn.directories.get(@conn.aliyun_oss_bucket)
    files = directory.files
    expect(files.length).to eq(1)
    expect(files.empty?).to eq(false)
    file=files.get('test_dir/dir1/dir2/dir3/')
    expect(file.key).to eq("test_dir/dir1/dir2/dir3/")
    file.destroy
    # nested files in nested directory
    file = Tempfile.new('fog-upload-file')
    file.write("Hello World!")
    begin
      system("aliyun oss mkdir oss://#{@conn.aliyun_oss_bucket}/test_dir/dir1/dir2 > /dev/null")
      system("aliyun oss appendfromfile #{file.path} oss://#{@conn.aliyun_oss_bucket}/test_dir/dir1/dir2/test_file > /dev/null")
      files = @conn.directories.get(@conn.aliyun_oss_bucket).files
      expect(files.length).to eq(2)
      expect(files.empty?).to eq(false)
      expect(files.get("test_dir/dir1/dir2/").key).to eq("test_dir/dir1/dir2/")
      expect(files.get("test_dir/dir1/dir2/test_file").key).to eq("test_dir/dir1/dir2/test_file")
      files.get("test_dir/dir1/dir2/").destroy
      files.get("test_dir/dir1/dir2/test_file").destroy
    ensure
      file.close
      file.unlink
    end
  end
  it 'test get file that not exists' do
    directory = @conn.directories.get(@conn.aliyun_oss_bucket)
    files = directory.files
    file = files.get('test_dir/test_file_not_exists')
    expect(file).to eq(nil)
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

  it 'Should delete 2 directories in bucket' do
    system("aliyun oss mkdir oss://#{@conn.aliyun_oss_bucket}/test_dir1 > /dev/null")
    system("aliyun oss mkdir oss://#{@conn.aliyun_oss_bucket}/test_dir2 > /dev/null")
    expect(@conn.directories.all.length).to eq(2)
    file = @conn.directories.get(@conn.aliyun_oss_bucket, prefix:'test_dir1').files[0]
    file.destroy
    expect(@conn.directories.all.length).to eq(1)
    file = @conn.directories.get(@conn.aliyun_oss_bucket, prefix:'test_dir').files[0]
    file.destroy
    expect(@conn.directories.all).to eq(nil)
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

  it 'Should delete 2 tests file in the root of bucket' do
    file = Tempfile.new('fog-upload-file')
    file.write("Hello World!")
    begin
      system("aliyun oss appendfromfile #{file.path} oss://#{@conn.aliyun_oss_bucket}/test_file1 > /dev/null")
      system("aliyun oss appendfromfile #{file.path} oss://#{@conn.aliyun_oss_bucket}/test_file2 > /dev/null")
      files = @conn.directories.get(@conn.aliyun_oss_bucket).files
      expect(files.length).to eq(2)
      expect(files.all.length).to eq(2)
      expect(files.empty?).to eq(false)
      files[0].destroy
      expect(@conn.directories.get(@conn.aliyun_oss_bucket).files.length).to eq(1)
      files[1].destroy
      expect(@conn.directories.get(@conn.aliyun_oss_bucket).files.length).to eq(0)
    ensure
      file.close
      file.unlink
    end
  end

  it 'Should upload(write) a file in the root of bucket' do
    directory = @conn.directories.get(@conn.aliyun_oss_bucket)
    directory.files.create :key => 'lorem.txt', :body => File.open('./spec/fog/lorem.txt')
    files = @conn.directories.get(@conn.aliyun_oss_bucket).files
    expect(files.length).to eq(1)
    expect(files.all.length).to eq(1)
    expect(files.empty?).to eq(false)
    files[0].destroy
    expect(@conn.directories.get(@conn.aliyun_oss_bucket).files.length).to eq(0)
  end

  it 'Should upload(write) a large file(more than 100M) in the root of bucket' do
    if !File.exist?("morethan100m")
      system("wget https://bosh.oss-cn-hangzhou.aliyuncs.com/fog/morethan100m -O morethan100m --show-progress")
    end
    directory = @conn.directories.get(@conn.aliyun_oss_bucket)
    directory.files.create :key => 'morethan100m', :body => File.open('morethan100m')
    files = @conn.directories.get(@conn.aliyun_oss_bucket).files
    expect(files.length).to eq(1)
    expect(files.all.length).to eq(1)
    expect(files.empty?).to eq(false)
    expect(files.head(files[0].key).content_length).to eq(140_356_457)
    files[0].destroy
    expect(@conn.directories.get(@conn.aliyun_oss_bucket).files.length).to eq(0)
  end

  it 'Should create a file and update in-place when putting string content to an object.' do
    # Ensure there is no any file
    files = @conn.directories.get(@conn.aliyun_oss_bucket).files
    expect(files.length).to eq(0)

    # Create a new file
    files.create :key => 'test_file_save', :body => "Hello World!"
    files = @conn.directories.get(@conn.aliyun_oss_bucket).files
    expect(files.length).to eq(1)
    expect(files[0].key).to eq("test_file_save")
    expect(files.get("test_file_save").content_length).to eq(12)

    # Update the file in-place
    files.create :key => 'test_file_save', :body => 'Hello World!Hello World!'
    files = @conn.directories.get(@conn.aliyun_oss_bucket).files
    expect(files.length).to eq(1)
    expect(files[0].key).to eq("test_file_save")
    expect(files.get("test_file_save").content_length).to eq(24)

    # Delete the file in-place
    files[0].destroy
    expect(@conn.directories.get(@conn.aliyun_oss_bucket).files.length).to eq(0)
  end

  it 'Should create a file and update in-place when putting a file to an object.' do
    # Ensure there is no any file
    files = @conn.directories.get(@conn.aliyun_oss_bucket).files
    expect(files.length).to eq(0)

    # Create a new file
    files.create :key => 'test_file_save', :body => File.open('./spec/fog/lorem.txt')
    files = @conn.directories.get(@conn.aliyun_oss_bucket).files
    expect(files.length).to eq(1)
    expect(files[0].key).to eq("test_file_save")
    expect(files.get("test_file_save").content_length).to eq(446)

    # Update the file in-place
    files.create :key => 'test_file_save', :body => File.open('./spec/fog/lorem2.txt')
    files = @conn.directories.get(@conn.aliyun_oss_bucket).files
    expect(files.length).to eq(1)
    expect(files[0].key).to eq("test_file_save")
    expect(files.get("test_file_save").content_length).to eq(14)

    # Delete the file in-place
    files[0].destroy
    expect(@conn.directories.get(@conn.aliyun_oss_bucket).files.length).to eq(0)
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
      expect(files.length).to eq(2)
      expect(files.get("test_dir/test_file").key).to eq("test_dir/test_file")
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
      expect(files.get("test_dir/test_file1").key).to eq("test_dir/test_file1")
      expect(files.get("test_dir/test_file2").key).to eq("test_dir/test_file2")
    ensure
      file.close
      file.unlink
    end
  end

  # According to AliCloud documentation Max-keys parameter can get from 1 to 1000 value.
  # In AWS the default is standing on 1000,
  # https://github.com/fog/fog-aws/blob/daa50bb3717a462baf4d04d0e0cbfc18baacb541/lib/fog/aws/requests/storage/get_bucket.rb#L81
  # NOTE: This test case will cost more than 30 minutes and please be patient.
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
        expect(files.get("test_dir/test_file#{n}").key).to eq("test_dir/test_file#{n}")
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

  # all of oss objects are ordered alphabetically
  # setting marker will return all of directories after marker
  it 'Should find directory using bucket name and marker' do
    system("aliyun oss mkdir oss://#{@conn.aliyun_oss_bucket}/a_test_dir1 > /dev/null")
    system("aliyun oss mkdir oss://#{@conn.aliyun_oss_bucket}/a_test_dir2 > /dev/null")
    system("aliyun oss mkdir oss://#{@conn.aliyun_oss_bucket}/b_test_dir1 > /dev/null")
    system("aliyun oss mkdir oss://#{@conn.aliyun_oss_bucket}/b_test_dir2 > /dev/null")
    system("aliyun oss mkdir oss://#{@conn.aliyun_oss_bucket}/c_test_dir1 > /dev/null")
    system("aliyun oss mkdir oss://#{@conn.aliyun_oss_bucket}/c_test_dir2 > /dev/null")
    bucket = @conn.directories.get(@conn.aliyun_oss_bucket, marker: "b_test")
    expect(bucket.files.size).to eq(4)
  end

  it 'Should find directory using bucket name and Max-keys' do
    system("aliyun oss mkdir oss://#{@conn.aliyun_oss_bucket}/a_test_dir1 > /dev/null")
    system("aliyun oss mkdir oss://#{@conn.aliyun_oss_bucket}/a_test_dir2 > /dev/null")
    system("aliyun oss mkdir oss://#{@conn.aliyun_oss_bucket}/b_test_dir1 > /dev/null")
    system("aliyun oss mkdir oss://#{@conn.aliyun_oss_bucket}/b_test_dir2 > /dev/null")
    system("aliyun oss mkdir oss://#{@conn.aliyun_oss_bucket}/c_test_dir1 > /dev/null")
    system("aliyun oss mkdir oss://#{@conn.aliyun_oss_bucket}/c_test_dir2 > /dev/null")
    bucket = @conn.directories.get(@conn.aliyun_oss_bucket, max_keys: 2)
    expect(bucket.files.size).to eq(2)
  end

  it 'Should find directory using bucket name and Delimiter' do
    file = Tempfile.new('fog-upload-file')
    file.write("Hello World!")
    begin
      system("aliyun oss mkdir oss://#{@conn.aliyun_oss_bucket}/test_dir1/test_sub_dir > /dev/null")
      system("aliyun oss mkdir oss://#{@conn.aliyun_oss_bucket}/test_dir2/test_sub_dir > /dev/null")
      system("aliyun oss appendfromfile #{file.path} oss://#{@conn.aliyun_oss_bucket}/test_dir1/test_file1 > /dev/null")
      system("aliyun oss appendfromfile #{file.path} oss://#{@conn.aliyun_oss_bucket}/test_dir1/test_sub_dir/test_file2 > /dev/null")
      bucket = @conn.directories.get(@conn.aliyun_oss_bucket, prefix: 'test_dir1')
      expect(bucket.files.size).to eq(3)
      bucket = @conn.directories.get(@conn.aliyun_oss_bucket, prefix: 'test_dir1/')
      expect(bucket.files.size).to eq(3)
      bucket = @conn.directories.get(@conn.aliyun_oss_bucket, prefix: 'test_dir1', delimiter: '/')
      expect(bucket.files.size).to eq(2)
      bucket = @conn.directories.get(@conn.aliyun_oss_bucket, prefix: 'test_dir1/', delimiter: '/')
      expect(bucket.files.size).to eq(1)
    ensure
      file.close
      file.unlink
    end
  end

  it 'Should find files using prefix, marker, max_keys and delimiter' do
    file = Tempfile.new('fog-upload-file')
    file.write("Hello World!")
    begin
      system("aliyun oss appendfromfile #{file.path} oss://#{@conn.aliyun_oss_bucket}/a_test_file1 > /dev/null")
      system("aliyun oss appendfromfile #{file.path} oss://#{@conn.aliyun_oss_bucket}/a_test_file2 > /dev/null")
      system("aliyun oss appendfromfile #{file.path} oss://#{@conn.aliyun_oss_bucket}/b_test_file1 > /dev/null")
      system("aliyun oss appendfromfile #{file.path} oss://#{@conn.aliyun_oss_bucket}/b_test_file2 > /dev/null")
      system("aliyun oss appendfromfile #{file.path} oss://#{@conn.aliyun_oss_bucket}/c_test_file1 > /dev/null")
      system("aliyun oss appendfromfile #{file.path} oss://#{@conn.aliyun_oss_bucket}/c_test_file2 > /dev/null")
      files = @conn.directories.get(@conn.aliyun_oss_bucket).files
      # filtered by prefix
      expect(files.length).to eq(6)
      expect(files.all(prefix:'b_test').length).to eq(2)
      expect(files.empty?).to eq(false)
      expect(files[0].key).to eq("b_test_file1")
      expect(files[1].key).to eq("b_test_file2")

      # filtered by marker
      expect(files.all(marker:'b_test').length).to eq(4)
      expect(files.empty?).to eq(false)
      expect(files[0].key).to eq("b_test_file1")
      expect(files[2].key).to eq("c_test_file1")

      # filtered by max_keys
      expect(files.all(max_keys:2).length).to eq(2)
      expect(files.empty?).to eq(false)
      expect(files[0].key).to eq("a_test_file1")
      expect(files[1].key).to eq("a_test_file2")

      # filtered by delimiter
      system("aliyun oss mkdir oss://#{@conn.aliyun_oss_bucket}/test_dir1/test_sub_dir > /dev/null")
      system("aliyun oss mkdir oss://#{@conn.aliyun_oss_bucket}/test_dir2/test_sub_dir > /dev/null")
      system("aliyun oss appendfromfile #{file.path} oss://#{@conn.aliyun_oss_bucket}/test_dir1/test_file1 > /dev/null")
      system("aliyun oss appendfromfile #{file.path} oss://#{@conn.aliyun_oss_bucket}/test_dir1/test_sub_dir/test_file2 > /dev/null")
      files = @conn.directories.get(@conn.aliyun_oss_bucket).files
      expect(files.all(prefix:'test_dir1').length).to eq(2)
      expect(files.all(prefix:'test_dir1/').length).to eq(2)
      expect(files.all(prefix:'test_dir1', delimiter: '/')).to eq(nil)
      expect(files.all(prefix:'test_dir1/', delimiter: '/').length).to eq(1)
      expect(files.empty?).to eq(false)
      expect(files[0].key).to eq("test_dir1/test_file1")
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
 it 'Should find directory using bucket name and prefix when bucket with the same name as directory exists without prefix' do
   file = Tempfile.new('fog-upload-file')
   file.write("Hello World!")
   begin
     dir_name=rand(36**16).to_s(36)
     system("aliyun oss mb oss://#{dir_name} > /dev/null")
     system("aliyun oss mkdir oss://#{@conn.aliyun_oss_bucket}/#{dir_name} > /dev/null")
     system("aliyun oss appendfromfile #{file.path} oss://#{@conn.aliyun_oss_bucket}/#{dir_name}/test_file > /dev/null")
     directory = @conn.directories.get(dir_name)
     expect(directory.files.size).to eq(0) # test file
   ensure
     file.close
     file.unlink
   end
 end

  it 'Should error is thrown when trying to destroy non-existing bucket' do
    bucket_name='test-bucket'+rand(36**16).to_s(36)
    begin
      resp=@conn.delete_bucket bucket_name
    rescue Exception => e
      p e.class
    end
  end

  # Test region is selected according to provider configuration
  # check default region is used if no region provided explicitly
  # There is need to set a env variable to support setting oss default bucket
  if ENV['ALIYUN_OSS_DEFAULT_BUCKET']
    default_bucket = ENV['ALIYUN_OSS_DEFAULT_BUCKET']
    it 'Should create a new directory' do
      bucket = @conn.directories.get(@conn.aliyun_oss_bucket)
      bucket.files.create :key => 'test_dir/'
      expect(bucket.files.get("test_dir/").key).to eq("test_dir/")
      expect(bucket.key[0]).to eq(@conn.aliyun_oss_bucket)
      @conn = Fog::Storage.new({
                                   :aliyun_accesskey_id => @conn.aliyun_accesskey_id,
                                   :aliyun_accesskey_secret => @conn.aliyun_accesskey_secret,
                                   :provider => "Aliyun",
                                   :aliyun_oss_bucket => default_bucket
                               })
      bucket = @conn.directories.get(@conn.aliyun_oss_bucket)
      bucket.files.create :key => 'test_dir/'
      expect(bucket.files.get("test_dir/").key).to eq("test_dir/")
      expect(bucket.key[0]).to eq(default_bucket)
    end
  end
end