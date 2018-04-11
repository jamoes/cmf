module CMF

  # Instances of the `Parser` class can parse CMF messages.
  #
  # Basic usage:
  #
  #     p = CMF::Parser.new
  #     p.parse("\x04\r")   # {0=>true, 1=>false}
  #     p.parse_hex("040d") # {0=>true, 1=>false}
  #
  # Using a dictionary:
  #
  #     p = CMF::Parser.new([:tag0, :tag1])
  #     p.parse_hex("040d") # {:tag0=>true, :tag1=>false}
  #
  # If a tag is found multiple times in the message, its values will be stored
  # in an array in the parsed object.
  #
  #     CMF::Parser.new.parse_hex("040504") # {0=>[true, false, true]}
  #
  # Using {next_pair}:
  #
  #     p = CMF::Parser.new
  #     p.message_hex = "040d"
  #     p.next_pair # [0, true]
  #     p.next_pair # [1, false]
  #     p.next_pair # nil
  #
  # Using {each}:
  #
  #     p = CMF::Parser.new
  #     p.messge_hex = "040d"
  #     p.each { |k, v| puts "#{k}: #{v}" }
  class Parser
    # @return {Hash} The inverted dictionary, mapping numbers to tag names.
    attr_reader :inverted_dictionary

    # Creates a new instance of {Parser}.
    #
    # @param dictionary [Hash,Array] Optional. The dictionary mapping tag
    #     names to numbers. See {Dictionary.validate}.
    def initialize(dictionary = nil)
      @inverted_dictionary = Dictionary.validate(dictionary).invert
      @io = StringIO.new
    end

    # Sets a new CMF message.
    #
    # @param message [String] The CMF message in octet form.
    def message=(message)
      @io = StringIO.new(message)
    end

    # Sets a new CMF message from a hex string.
    #
    # @param message_hex [String] The hex-encoded CMF message.
    def message_hex=(message_hex)
      self.message = [message_hex].pack('H*')
    end

    # Parses a CMF message into an object.
    #
    # @param message [String] The message to parse. If none provided, this
    #     parser's existing message (defined from {message=} or {message_hex=}
    #     will be parsed.
    # @return [Hash] A hash mapping the messages tags to their values. For each
    #     tag, if the tag number is found in the dictionary, its associated
    #     tag name will be used as hash key. If a tag is found multiple times
    #     in the message, its values will be stored in an array in the parsed
    #     object.
    def parse(message = nil)
      self.message = message if message

      obj = {}
      each do |key, value|
        if obj.has_key?(key)
          obj[key] = Array(obj[key])
          obj[key] << value
        else
          obj[key] = value
        end
      end

      obj
    end

    # Parses a hex-encoded CMF message into an object.
    #
    # @param message_hex [String] A hex-encoded CMF message.
    # @return [Hash] See {parse}.
    def parse_hex(message_hex)
      self.message_hex = message_hex

      parse
    end

    # Calls the given block once for each pair found in the message.
    #
    # @yieldparam [Integer,Object] tag The pair's tag. An integer, or the
    #     associated value found in the dictionary.
    # @yieldparam [String,Integer,Boolean,Float] value The pair's value.
    # @return [Enumerator] If no block is given.
    # @see #next_pair
    def each
      return to_enum(:each) unless block_given?
      loop do
        pair = next_pair
        break if pair.nil?
        yield(pair[0], pair[1])
      end
    end

    # Returns the next pair in the message, or nil if the whole message has been
    # parsed.
    #
    # @return [Array,nil] A (tag, value) pair. The tag will be an integer, or
    #     the associated value found in the dictionary. The value will be
    #     converted to the corresponding type defined in the message. If the
    #     value's type is {Type::STRING}, the value will be a string with UTF-8
    #     encoding. If the value's type is {Type::BYTE_ARRAY}, the value will
    #     be a string with binary (ASCII-8BIT) encoding.
    #
    # @raise [MalformedMessageError] if the CMF message cannot be parsed, or if
    #     it is malformed in any way.
    def next_pair
      return nil if @io.eof?

      byte = @io.getbyte
      type = byte & 0x07
      tag = byte >> 3
      if tag == 31
        tag = Varint.deserialize(@io)
      end

      if @inverted_dictionary[tag]
        tag = @inverted_dictionary[tag]
      end

      case type
      when Type::POSITIVE_NUMBER
        [tag, Varint.deserialize(@io)]
      when Type::NEGATIVE_NUMBER
        [tag, -Varint.deserialize(@io)]
      when Type::STRING, Type::BYTE_ARRAY
        length = Varint.deserialize(@io)
        s = @io.read(length)
        s.bytesize == length or raise MalformedMessageError, "Unexpected end of stream"
        s = s.force_encoding(Encoding::UTF_8) if type == Type::STRING
        [tag, s]
      when Type::BOOL_TRUE
        [tag, true]
      when Type::BOOL_FALSE
        [tag, false]
      when Type::DOUBLE
        s = @io.read(8)
        s.bytesize == 8 or raise MalformedMessageError, "Unexpected end of stream"
        [tag, s.unpack('E').first]
      else
        raise MalformedMessageError, "Unknown type"
      end

    end
  end
end
