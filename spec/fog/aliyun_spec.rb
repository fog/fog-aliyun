# frozen_string_literal: true

require 'spec_helper'
require 'addressable'

describe Fog::Aliyun do
  it 'has a version number' do
    expect(Fog::Aliyun::VERSION).not_to be nil
  end

  it 'does something useful' do
    expect(true).to eq(true)
  end

  it 'encodes uris' do
    all_ascii_chars_plus_space = '!"#$%&\'()*+,-./0123456789:;<=>?@ABCDEFGHIJKLMNOPQRSTUVWXYZ[\]^_`abcdefghijklmnopqrstuvwxyz{|}~ '
    # The above string encoded with URI.encode(all_ascii_chars_plus_space, '/[^!*\'()\;?:@#&%=+$,{}[]<>`" '):
    uri_encoded_string = '%21%22%23%24%25%26%27%28%29%2A%2B%2C-.%2F0123456789%3A%3B%3C%3D%3E%3F%40ABCDEFGHIJKLMNOPQRSTUVWXYZ%5B%5C%5D%5E_%60abcdefghijklmnopqrstuvwxyz%7B|%7D~%20'

    encoded_string = Addressable::URI.encode_component(all_ascii_chars_plus_space, Addressable::URI::CharacterClasses::UNRESERVED + '|')
    expect(encoded_string).to eq(uri_encoded_string)
  end
end
