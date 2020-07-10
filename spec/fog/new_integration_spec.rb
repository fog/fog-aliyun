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
end