require 'spec_helper'
require 'messages'

describe CMF::Builder do

  MESSAGES.each do |obj, encoded_output, dictionary|
    it "Builds message #{encoded_output}" do
      expect(CMF.build_hex(obj, dictionary)).to eq encoded_output
    end
  end

  it 'Builds octet message' do
    expect(CMF.build({0 => false})).to eq("\x05".force_encoding(Encoding::BINARY))
  end

  describe '#reset' do
    it 'resets the message' do
      builder = CMF::Builder.new
      builder.add(0, 0)
      builder.reset
      expect(builder.to_hex).to eq ''
    end
  end

  describe '#add' do
    it 'raises when tag not found in dictionary' do
      expect { CMF::Builder.new.add(:tag, 0) }.to raise_error(ArgumentError)
    end

    it 'raises when tag is negative' do
      expect { CMF::Builder.new.add(-1, 0) }.to raise_error(ArgumentError)
    end

    it 'accepts chained calls' do
      expect(CMF::Builder.new.add(0, true).add(0, false).to_hex).to eq "0405"
    end

    it 'converts unknown input type to a string' do
      expect(CMF::Builder.new.add(0, []).to_hex).to eq "02025b5d"
    end
  end

  describe '#add_int' do
    it 'converts non-int input to an int' do
      expect(CMF::Builder.new.add_int(15, "6512").to_hex).to eq "78b170"
      expect(CMF::Builder.new.add_int(15, 6512.1).to_hex).to eq "78b170"
    end
  end

  describe '#add_string' do
    it 'converts non-string input to a string' do
      expect(CMF::Builder.new.add_string(0, []).to_hex).to eq "02025b5d"
    end
  end

  describe '#add_bytes' do
    it 'converts non-string input to a string' do
      expect(CMF::Builder.new.add_bytes(0, []).to_hex).to eq "03025b5d"
    end
  end

  describe '#add_bool' do
    it 'converts non-bool input to a bool' do
      expect(CMF::Builder.new.add_bool(0, []).to_hex).to eq "04"
      expect(CMF::Builder.new.add_bool(0, nil).to_hex).to eq "05"
    end
  end

  describe '#add_double' do
    it 'converts non-double input to a double' do
      expect(CMF::Builder.new.add_double(0, "1.1").to_hex).to eq "069a9999999999f13f"
    end
  end
end
