require 'spec_helper'
require 'messages'

describe CMF::Parser do

  MESSAGES.each do |obj, encoded_output, dictionary|
    it "Parses message #{encoded_output}" do
      expect(CMF.parse_hex(encoded_output, dictionary)).to eq obj
    end
  end

  # Invalid messages:
  [
    '00', # Number type, but no data.
    '00ff', # Number type, but invalid varint data.
    '0700', # Unknown type.
    '020261', # String type, but string data is less than length.
    '069a9999999999b9', # Double type, but only 7 bytes of data.
  ].each do |invalid_message|
    it "Raises on invalid message: #{invalid_message}" do
      expect { CMF.parse_hex(invalid_message) }.to raise_error(CMF::MalformedMessageError)
    end
  end

  it 'Parses hex' do
    p = CMF::Parser.new
    p.message_hex = '05'

    expect(p.parse).to eq({0 => false})
    expect(p.parse_hex('05')).to eq({0 => false})
  end

  it 'Parses octet' do
    expect(CMF.parse("\x04")).to eq({0 => true})
  end
end
