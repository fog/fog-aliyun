require 'spec_helper'
require 'find'

describe 'blobstore tests', :blobstore => true do

  before(:all) do
    @conn = Fog::Storage[:aliyun]
    Fog::Logger.debug('Initializing Aliyun CLI for blobstore test population...')
    system("aliyun configure set --language en --region #{@conn.aliyun_region_id} --access-key-id #{@conn.aliyun_accesskey_id} --access-key-secret #{@conn.aliyun_accesskey_secret}")
  end

  before(:each) do
    Fog::Logger.debug("Initializing oss bucket for tests: #{@conn.aliyun_oss_bucket}")
    system("aliyun oss rm --bucket oss://#{@conn.aliyun_oss_bucket} -r -f > /dev/null || exit 0")
    system("aliyun oss mb oss://#{@conn.aliyun_oss_bucket} > /dev/null")
  end

  it 'blobstore cp_to_blobstore' do
    files=@conn.directories.get(@conn.aliyun_oss_bucket).files
    expect(files.size).to eq(0)
    files.create :key=>"file1",:body=>"hello"
    files=@conn.directories.get(@conn.aliyun_oss_bucket).files
    expect(files.size).to eq(1)
    files.create :key=>"file2",:body=>::File.open("spec/fog/lorem.txt","r")
    files=@conn.directories.get(@conn.aliyun_oss_bucket).files
    expect(files.size).to eq(2)
  end

  it 'blobstore exists' do
    files=@conn.directories.get(@conn.aliyun_oss_bucket).files
    expect(files.head("file1")).to eq(nil)
    files.create :key=>"file1",:body=>"hello"
    expect(files.head("file1")).not_to eq(nil)
  end

  it 'blobstore download_from_blobstore' do
    files=@conn.directories.get(@conn.aliyun_oss_bucket).files
    expect(files.size).to eq(0)
    files.create :key=>"file1",:body=>"hello"
    files=@conn.directories.get(@conn.aliyun_oss_bucket).files
    expect(files.size).to eq(1)
    File.open("1.txt","wb") do |file|
      files.get("file1") do |*chunk|
        file.write(chunk[0])
      end
    end
  end

  it 'blobstore cp_r_to_blobstore' do
    files=@conn.directories.get(@conn.aliyun_oss_bucket).files
    Find.find("spec/fog").each do |path|
      next unless File.file? path
      next unless path.include? ".txt"
      files.create :key=>path,:body=>File.open(path,"r") unless files.head(path)
    end
    files=@conn.directories.get(@conn.aliyun_oss_bucket).files
    expect(files.size).to eq(2)
  end

  it 'blobstore cp_file_between_keys' do
    files=@conn.directories.get(@conn.aliyun_oss_bucket).files
    expect(files.size).to eq(0)
    files.create :key=>"file1",:body=>"hello"
    files=@conn.directories.get(@conn.aliyun_oss_bucket).files
    expect(files.size).to eq(1)
    files.get("file1").copy(@conn.aliyun_oss_bucket,"file2")
    files=@conn.directories.get(@conn.aliyun_oss_bucket).files
    expect(files.size).to eq(2)
  end

  it 'blobstore delete_all' do
    files=@conn.directories.get(@conn.aliyun_oss_bucket).files
    expect(files.size).to eq(0)
    files.create :key=>"file1",:body=>"hello"
    files.create :key=>"file2",:body=>"hello2"
    files=@conn.directories.get(@conn.aliyun_oss_bucket).files
    expect(files.size).to eq(2)
    files.each { |file| file.destroy }
    files=@conn.directories.get(@conn.aliyun_oss_bucket).files
    expect(files.size).to eq(0)
  end

  it 'blobstore delete part' do
    files=@conn.directories.get(@conn.aliyun_oss_bucket).files
    expect(files.size).to eq(0)
    files.create :key=>"dir1/file1",:body=>"hello"
    files.create :key=>"dir1/file2",:body=>"hello2"
    files.create :key=>"dir2/file1",:body=>"hello"
    files.create :key=>"dir2/file2",:body=>"hello2"
    files=@conn.directories.get(@conn.aliyun_oss_bucket).files
    expect(files.size).to eq(4)
    files=@conn.directories.get(@conn.aliyun_oss_bucket,prefix:"dir1").files
    files.each { |file| file.destroy }
    files=@conn.directories.get(@conn.aliyun_oss_bucket).files
    expect(files.size).to eq(2)
  end

end