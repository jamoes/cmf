module CMF
  # Provides functionaly for serializing and deserializing variable-width
  # encoded integers (varint).
  class Varint

    # Serializes an integer into a varint.
    #
    # @param io [StringIO] The IO stream where the serialized varint will be
    #     written.
    # @param n [Integer] The integer to serialize.
    # @return [nil]
    def self.serialize(io, n)
      n.is_a?(Integer) or raise TypeError, "Invalid Varint value #{n}. Must be an integer"
      n >= 0 or raise ArgumentError, "Invalid Varint value #{n}. Must be >= 0"

      data = []
      mask = 0
      begin
        data.push((n & 0x7F) | mask)
        n = (n >> 7) - 1
        mask = 0x80
      end while n >= 0

      data.reverse_each do |byte|
        io.putc(byte)
      end

      nil
    end

    # Deserializes a varint into a integer.
    #
    # @param io [StringIO] The IO stream that will be read from to deserialize.
    # @return [Integer] The deserialized integer.
    def self.deserialize(io)
      result = 0
      io.each_byte do |byte|
        result = (result << 7) | (byte & 0x7F)
        return result if (byte & 0x80) == 0
        result += 1
      end
      raise CMF::MalformedMessageError, "Unexpected end of stream"
    end
  end
end
