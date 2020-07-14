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
    # TODO test directories.get options, like prefix, max_keys and so on
    files = @conn.directories.get(@conn.aliyun_oss_bucket,prefix:"test_dir2").files
    expect(files.length).to eq(1)
    files = @conn.directories.get(@conn.aliyun_oss_bucket,max_keys:"1").files
    expect(files.length).to eq(1)
    system("aliyun oss mkdir oss://#{@conn.aliyun_oss_bucket}/test_dir3/dir1 > /dev/null")
    system("aliyun oss mkdir oss://#{@conn.aliyun_oss_bucket}/test_dir4/dir1 > /dev/null")
    files = @conn.directories.get(@conn.aliyun_oss_bucket,marker:"test_dir2").files
    expect(files.length).to eq(3)
    files = @conn.directories.get(@conn.aliyun_oss_bucket,delimiter:"/").files
    expect(files.length).to eq(0)
    files = @conn.directories.get(@conn.aliyun_oss_bucket,prefix:"test_dir2/dir1/",delimiter:"/").files
    expect(files.length).to eq(1)
  end

  it 'Should create a new directory' do
    directory_key = DIRECTORY_TEST_PREFIX + 'create-' + rand(100).to_s
    @conn.directories.create :key => directory_key
    # TODO support parameter :location : @conn.directories.create :key => directory_key, :location => "oss-eu-central-1"
    directory = @conn.directories.get(directory_key)
    expect(directory.key).to eq(directory_key)
    # TODO checking other attributes of directory
    expect(directory.location).to eq('oss-' + @conn.aliyun_region_id)
    # TODO checking other methods of directory
    files = directory.files
    expect(files.length).to eq(0)
    directory.destroy!
    directory = @conn.directories.get(directory_key)
    expect(directory).to eq(nil)
  end

  it 'Should delete directory' do
    directory_key = @conn.aliyun_oss_bucket + '-delete'
    system("aliyun oss mb oss://#{directory_key} > /dev/null")
    directory = @conn.directories.get(directory_key)
    expect(directory.key).to eq(directory_key)
    # TODO checking other attributes of directory
    files = directory.files
    expect(files.length).to eq(0)
    directory.destroy
    directory = @conn.directories.get(directory_key)
    expect(directory).to eq(nil)
  end

  it 'Should delete! directory' do
    directory_key = @conn.aliyun_oss_bucket + '-delete-2'
    system("aliyun oss mb oss://#{directory_key} > /dev/null")
    system("aliyun oss mkdir oss://#{directory_key}/test_dir/dir1/dir2/dir3 > /dev/null")
    system("aliyun oss mkdir oss://#{directory_key}/test_dir2/dir1 > /dev/null")
    directory = @conn.directories.get(directory_key)
    expect(directory.key).to eq(directory_key)
    # TODO checking other attributes of directory
    files = directory.files
    expect(files.length).to eq(2)
    directory.destroy!
    directory = @conn.directories.get(directory_key)
    expect(directory).to eq(nil)
  end

  it 'Should get all of files: test files.all' do
    directory_key = @conn.aliyun_oss_bucket
    file = Tempfile.new('fog-upload-file')
    file.write("Hello World!")
    begin
      system("aliyun oss mkdir oss://#{directory_key}/test_dir1 > /dev/null")
      system("aliyun oss cp #{file.path} oss://#{directory_key}/test_dir1/test_file1 > /dev/null")
      system("aliyun oss mkdir oss://#{directory_key}/test_dir2 > /dev/null")
      system("aliyun oss cp #{file.path} oss://#{directory_key}/test_dir2/test_file2 > /dev/null")
      system("aliyun oss cp #{file.path} oss://#{directory_key}/test_file3 > /dev/null")
      files = @conn.directories.get(directory_key).files
      expect(files.length).to eq(5)
      expect(files.all.length).to eq(5)
      # TODO support more filter, like delimiter，marker，prefix, max_keys
      expect(files.all(delimiter:"/").length).to eq(1)
      expect(files.all(marker:"test_dir2").length).to eq(3)
      expect(files.all(prefix:"test_dir1").length).to eq(2)
      expect(files.all(max_keys:"3").length).to eq(3)
      expect(files.all(prefix:"test_dir1",max_keys:"1").length).to eq(1)
      expect(files.all(prefix:"test_dir1/",delimiter:"/").length).to eq(2)
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
      system("aliyun oss mkdir oss://#{directory_key}/test_dir1 > /dev/null")
      system("aliyun oss cp #{file.path} oss://#{directory_key}/test_dir1/test_file1 > /dev/null")
      system("aliyun oss mkdir oss://#{directory_key}/test_dir2 > /dev/null")
      system("aliyun oss cp #{file.path} oss://#{directory_key}/test_dir2/test_file2 > /dev/null")
      system("aliyun oss cp #{file.path} oss://#{directory_key}/test_file3 > /dev/null")
      files = @conn.directories.get(directory_key).files
      # TODO test block
      expect(files.each.size).to eq(5)
      files.each { |f| expect(f.key).not_to eq(nil) }
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
      system("aliyun oss mkdir oss://#{directory_key}/test_dir1 > /dev/null")
      system("aliyun oss cp #{file.path} oss://#{directory_key}/test_dir1/test_file1 > /dev/null")
      system("aliyun oss mkdir oss://#{directory_key}/test_dir2 > /dev/null")
      system("aliyun oss cp #{file.path} oss://#{directory_key}/test_dir2/test_file2 > /dev/null")
      system("aliyun oss cp #{file.path} oss://#{directory_key}/test_file3 > /dev/null")
      files = @conn.directories.get(directory_key).files
      get_file = files.get("test_file3")
      expect(get_file.key).to eq("test_file3")
      # TODO checking all of file attributes and more files
      get_file=files.get('test_dir1/test_file1')
      expect(get_file.key).to eq("test_dir1/test_file1")
      expect(get_file.date).not_to eq(nil)
      expect(get_file.etag).not_to eq(nil)
      expect(get_file.last_modified).not_to eq(nil)
      get_file=files.get('test_dir1/')
      expect(get_file.key).to eq("test_dir1/")
      expect(get_file.date).not_to eq(nil)
      expect(get_file.etag).not_to eq(nil)
      expect(get_file.last_modified).not_to eq(nil)
    ensure
      file.close
      file.unlink
    end
  end

  it 'Should get specified file: test files.get_https_url' do
    files = @conn.directories.get(@conn.aliyun_oss_bucket).files
    expect(files.size).to eq(0)
    files.create :key=> "file1" ,:body=> File.open("spec/fog/lorem.txt","r")
    files = @conn.directories.get(@conn.aliyun_oss_bucket).files
    expect(files.get_https_url("file1",3600)).not_to eq(nil)
    expect(files.get_url("file1")).not_to eq(nil)
    expect(files.get_http_url("file1",3600)).not_to eq(nil)
  end

  it 'Should head the specified file: test files.head' do
    directory_key = @conn.aliyun_oss_bucket
    file = Tempfile.new('fog-upload-file')
    file.write("Hello World!")
    begin
      system("aliyun oss mkdir oss://#{directory_key}/test_dir1 > /dev/null")
      system("aliyun oss cp #{file.path} oss://#{directory_key}/test_dir1/test_file1 > /dev/null")
      system("aliyun oss mkdir oss://#{directory_key}/test_dir2 > /dev/null")
      system("aliyun oss cp #{file.path} oss://#{directory_key}/test_dir2/test_file2 > /dev/null")
      system("aliyun oss cp #{file.path} oss://#{directory_key}/test_file3 > /dev/null")
      files = @conn.directories.get(directory_key).files
      head_file = files.head("test_file3")
      expect(head_file.key).to eq("test_file3")
      # TODO checking all of file attributes and more files
      head_file=files.head('test_dir1/test_file1')
      expect(head_file.key).to eq("test_dir1/test_file1")
      expect(head_file.date).not_to eq(nil)
      expect(head_file.etag).not_to eq(nil)
      expect(head_file.last_modified).not_to eq(nil)
      head_file=files.head('test_dir1/')
      expect(head_file.key).to eq("test_dir1/")
      expect(head_file.date).not_to eq(nil)
      expect(head_file.etag).not_to eq(nil)
      expect(head_file.last_modified).not_to eq(nil)
    ensure
      file.close
      file.unlink
    end
  end

  it 'Should get the specified file acl: test file.acl' do
    directory_key = @conn.aliyun_oss_bucket
    file = Tempfile.new('fog-upload-file')
    file.write("Hello World!")
    begin
      system("aliyun oss cp #{file.path} oss://#{directory_key}/test_file > /dev/null")
      files = @conn.directories.get(directory_key).files
      expect(files[0].acl).to eq("default")
        # TODO checking other acl and set acl
      files[0].acl='public-read'
    ensure
      file.close
      file.unlink
    end
  end

  it 'Should copy a new directory: test file.copy' do
    source_directory_key = @conn.aliyun_oss_bucket
    target_directory_key = DIRECTORY_TEST_PREFIX + 'create-' + rand(100).to_s
    file = Tempfile.new('fog-upload-file')
    file.write("Hello World!")
    begin
      system("aliyun oss mb oss://#{target_directory_key} > /dev/null")
      system("aliyun oss cp #{file.path} oss://#{source_directory_key}/test_file > /dev/null")
      files = @conn.directories.get(source_directory_key).files
      files[0].copy(target_directory_key, "target_test_file")
      files = @conn.directories.get(target_directory_key).files
      expect(files[0].key).to eq("target_test_file")
        # TODO checking other acl and set acl
      directory = @conn.directories.get(target_directory_key)
      directory.acl='public-read-write'
      expect(directory.acl).to eq('public-read-write')
    ensure
      file.close
      file.unlink
      files = @conn.directories.get(target_directory_key).files
      files.each { |f| f.destroy }
      @conn.delete_bucket (target_directory_key)
    end
  end

  it 'Should delete the specified file: test file.destroy' do
    directory_key = @conn.aliyun_oss_bucket
    file = Tempfile.new('fog-upload-file')
    file.write("Hello World!")
    begin
      system("aliyun oss cp #{file.path} oss://#{directory_key}/test_file > /dev/null")
      files = @conn.directories.get(directory_key).files
      expect(files[0].key).to eq("test_file")
      files[0].destroy
      files = @conn.directories.get(directory_key).files
      expect(files.size).to eq(0)
      # TODO checking more files
      system("aliyun oss cp #{file.path} oss://#{directory_key}/test_file1 > /dev/null")
      system("aliyun oss cp #{file.path} oss://#{directory_key}/test_file2 > /dev/null")
      system("aliyun oss cp #{file.path} oss://#{directory_key}/test_file3 > /dev/null")
      files = @conn.directories.get(directory_key).files
      files[0].destroy
      files[1].destroy
      files = @conn.directories.get(directory_key).files
      expect(files.size).to eq(1)
    ensure
      file.close
      file.unlink
    end
  end

  it 'Should create the specified file: test file.save' do
    files = @conn.directories.get(@conn.aliyun_oss_bucket).files
    expect(files.size).to eq(0)
    files.create :key=> "file1" ,:body=> File.open("spec/fog/lorem.txt","r")
    files = @conn.directories.get(@conn.aliyun_oss_bucket).files
    expect(files.size).to eq(1)
    if !File.exist?("morethan100m")
      system("wget https://bosh.oss-cn-hangzhou.aliyuncs.com/fog/morethan100m -O morethan100m --show-progress")
    end
    files.create :key=> "file2", :body=> File.open("morethan100m","r")
    files = @conn.directories.get(@conn.aliyun_oss_bucket).files
    expect(files.size).to eq(2)
  end

  it 'Should get the specified file: test file.url' do
    files = @conn.directories.get(@conn.aliyun_oss_bucket).files
    files.create :key=> "file1" ,:body=> File.open("spec/fog/lorem.txt","r")
    expect(files.get("file1").url(3600)).not_to eq(nil)
  end

  it 'Should get nested directories and files in nested directory' do
    # nested directories
    system("aliyun oss mkdir oss://#{@conn.aliyun_oss_bucket}/test_dir/dir1/dir2/dir3 > /dev/null")
    directory = @conn.directories.get(@conn.aliyun_oss_bucket)
    files = directory.files
    expect(files.length).to eq(1)
    expect(files.empty?).to eq(false)
    expect(files.head('test_dir/dir1/notExistFile')).to eq(nil)
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

  it 'Should getting bucket when directory exists named with the same name as a bucket' do
    system("aliyun oss mkdir oss://#{@conn.aliyun_oss_bucket}/#{@conn.aliyun_oss_bucket} > /dev/null")
    files = @conn.directories.get(@conn.aliyun_oss_bucket).files
    expect(files.length).to eq(1)
    expect(files.get(@conn.aliyun_oss_bucket+"/").key).to eq(@conn.aliyun_oss_bucket+"/")
    files[0].destroy
  end

  it 'test get file that not exists' do
    directory = @conn.directories.get(@conn.aliyun_oss_bucket)
    files = directory.files
    file = files.get('test_dir/test_file_not_exists')
    expect(file).to eq(nil)
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

  it 'Should error is thrown when trying to access non-existing bucket' do
    bucket_name='test-bucket'+rand(36**16).to_s(36)
    begin
      @conn.get_bucket bucket_name
    rescue Exception => e
      expect(e.error_code).to eq("NoSuchBucket")
    end
  end

  it 'Should error is thrown when trying to create already existing bucket' do
    bucket_name="test-bucket"+rand(36**16).to_s(36)
    begin
      @conn.put_bucket bucket_name
      @conn.put_bucket bucket_name
    rescue Exception => e
      expect(e.error_code).to eq("BucketAlreadyExists")
    ensure
      @conn.delete_bucket bucket_name
    end
  end

  it 'Should possible to list all buckets' do
    b1=rand(36**16).to_s(36)
    b2=rand(36**16).to_s(36)
    b3=rand(36**16).to_s(36)
    b4=rand(36**16).to_s(36)
    b5=rand(36**16).to_s(36)
    b6=rand(36**16).to_s(36)
    @conn.put_bucket('bucket-test'+b1)
    @conn.put_bucket('bucket-test2'+b2)
    @conn.put_bucket('file-test'+b3)
    @conn.put_bucket('file-test2'+b4)
    @conn.put_bucket('directory-test'+b5)
    @conn.put_bucket('directory-test2'+b6)
    buckets=@conn.list_buckets[0]
    expect(buckets.length).to be >= 6
    buckets=(@conn.list_buckets :prefix=>"bucket")[0]
    expect(buckets.length).to be >=2
    buckets=(@conn.list_buckets :marker=>"file-t")[0]
    expect(buckets.length).to be >=4
    buckets=(@conn.list_buckets :max_keys=>"6")[0]
    expect(buckets.length).to be(6)
    #delete created bucket
    @conn.delete_bucket('bucket-test'+b1)
    @conn.delete_bucket('bucket-test2'+b2)
    @conn.delete_bucket('file-test'+b3)
    @conn.delete_bucket('file-test2'+b4)
    @conn.delete_bucket('directory-test'+b5)
    @conn.delete_bucket('directory-test2'+b6)
  end

  it 'Should can be accessed using valid credentials' do
    expect(@conn.list_objects(@conn.aliyun_oss_bucket)).not_to eq(nil)
  end

  it 'Should cannot be accessed using incorrect credentials' do
    @conn = Fog::Storage.new({
                                 :aliyun_accesskey_id => rand(36**16).to_s(36),
                                 :aliyun_accesskey_secret => rand(36**16).to_s(36),
                                 :provider => "Aliyun",
                                 :aliyun_oss_bucket => @conn.aliyun_oss_bucket
                             })
    begin
      @conn.list_objects(@conn.aliyun_oss_bucket)
    rescue  Exception => e
      expect(e.error_code).to include("InvalidAccessKeyId")
    end
  end

  it 'Should get bucket operation' do
    expect(@conn.get_bucket_acl(@conn.aliyun_oss_bucket)).to eq("private")
    begin
      @conn.get_bucket_CORSRules(@conn.aliyun_oss_bucket)
    rescue Exception => e
      expect(e.error_code).to eq("NoSuchCORSConfiguration")
    end
    begin
      @conn.get_bucket_lifecycle(@conn.aliyun_oss_bucket)
    rescue Exception => e
      expect(e.error_code).to eq("NoSuchLifecycle")
    end
    expect(@conn.get_bucket_referer(@conn.aliyun_oss_bucket).allow_empty).to eq(true)
    begin
      @conn.get_bucket_website(@conn.aliyun_oss_bucket)
    rescue Exception => e
      expect(e.error_code).to eq("NoSuchWebsiteConfiguration")
    end
    expect(@conn.get_bucket_logging(@conn.aliyun_oss_bucket)).not_to eq(nil)
  end

  it 'Should list object operation' do
    system("aliyun oss mkdir oss://#{@conn.aliyun_oss_bucket}/test_dir1/test_sub_dir > /dev/null")
    system("aliyun oss mkdir oss://#{@conn.aliyun_oss_bucket}/test_dir2/test_sub_dir > /dev/null")
    expect(@conn.list_objects(@conn.aliyun_oss_bucket,:prefix=>"test_dir1")[0].size).to eq(1)
    expect(@conn.list_objects(@conn.aliyun_oss_bucket,:marker=>"test_dir1")[0].size).to eq(2)
    upload_id=@conn.initiate_multipart_upload(@conn.aliyun_oss_bucket,"test_file1")
    expect(@conn.list_multipart_uploads(@conn.aliyun_oss_bucket)).not_to eq(nil)
    f=File.open("spec/fog/lorem.txt","r")
    @conn.upload_part(@conn.aliyun_oss_bucket, "test_file1", upload_id, 1, f.read)
    f.close
    expect(@conn.list_parts(@conn.aliyun_oss_bucket,"test_file1",upload_id)[0].size).to eq(1)
    @conn.abort_multipart_upload(@conn.aliyun_oss_bucket,"test_file1",upload_id)
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