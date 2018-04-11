require 'spec_helper'

describe CMF::Varint do

  number_encodings = {
    0X7F   => [0x7f],
    0X80   => [0x80, 0x00],
    0xFF   => [0x80, 0x7F],
    0x407F => [0xFF, 0x7F],
    0X4080 => [0x80, 0x80, 0x00],
  }

  describe '#serialize' do
    it 'serializes values correctly' do
      number_encodings.each do |number, encoded_number|
        io = StringIO.new(String.new)
        CMF::Varint.serialize(io, number)

        expect(io.string).to eq encoded_number.pack('c*')
      end
    end

    it 'does not serialize negative numbers' do
      io = StringIO.new(String.new)
      expect { CMF::Varint.serialize(io, -1) }.to raise_error(ArgumentError)
    end

    it 'Raises on invalid type' do
      io = StringIO.new(String.new)
      expect { CMF::Varint.serialize(io, "") }.to raise_error(TypeError)
    end
  end

  describe '#deserialize' do
    it 'deserializes values correctly' do
      number_encodings.invert.each do |encoded_number, number|
        io = StringIO.new(encoded_number.pack('c*'))
        decoded_number = CMF::Varint.deserialize(io)

        expect(number).to eq decoded_number
      end
    end

    it 'raises an error if the stream ends early' do
      io = StringIO.new([0x80].pack('c*'))
      expect { CMF::Varint.deserialize(io) }.to raise_error(CMF::MalformedMessageError)
    end
  end

end
