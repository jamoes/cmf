module CMF

  # Instances of the `Builder` class can create CMF messages.
  #
  # Basic usage:
  #
  #     b = CMF::Builder.new
  #     b.add(0, "value0")
  #     b.add(1, "value1")
  #
  # The CMF message can be output in octet form (one character per byte):
  #
  #     b.to_octet
  #
  # or hex form (two characters per byte):
  #
  #     b.to_hex
  #
  # Method calls can be chained together:
  #
  #     CMF::Builder.new.add(0, "value0").add(1, "value1").to_hex
  #
  # A dictionary can be used to refer to tags by name rather than number:
  #
  #     b = CMF::Builder.new([:tag0, :tag1])
  #     b.add(:tag0, "value0")
  #     b.add(:tag1, "value1")
  #
  # Messages can be built from an object:
  #
  #     b = CMF::Builder.new([:tag0, :tag1])
  #     b.build({tag0: "value0", tag1: "value1"})
  class Builder
    # @return {Hash} The dictionary mapping tag names to numbers.
    attr_reader :dictionary

    # Creates a new instance of {Builder}.
    #
    # @param dictionary [Hash,Array] Optional. The dictionary mapping tag
    #     names to numbers. See {Dictionary.validate}.
    def initialize(dictionary = nil)
      @dictionary = Dictionary.validate(dictionary)
      reset
    end

    # Resets the CMF message.
    #
    # @return [Builder] self
    def reset
      @io = StringIO.new(String.new) # A StringIO with ASCII-8BIT encoding

      self
    end

    # Adds multiple (tag, value) pairs to the CMF message.
    #
    # @param obj [Hash,#each] The object containing (tag, value) pairs. Can be
    #     a hash, or any object that responds to `.each` and yields
    #     (tag, value) pairs. Calls {add} for each (tag, value) pair.
    # @return [Builder] self
    # @see #add
    def build(obj)
      obj.each do |key, values|
        Array(values).each do |value|
          add(key, value)
        end
      end

      self
    end

    # Adds a (tag, value) pair to the CMF message.
    #
    # @param tag [Integer,Object] Must be an integer or a key in the
    #     dictionary.
    # @param value [String,Integer,Boolean,Float,Object] A string, integer,
    #     boolean, or float. All other types will be converted to a string by
    #     calling the `to_s` method on them. Strings with binary (ASCII-8BIT)
    #     encoding will be added as a {Type::BYTE_ARRAY}. All other strings
    #     will be added as a {Type::STRING}.
    # @return [Builder] self
    def add(tag, value)
      case value
      when Integer
        add_int(tag, value)
      when String
        if value.encoding == Encoding::BINARY
          add_bytes(tag, value)
        else
          add_string(tag, value)
        end
      when TrueClass, FalseClass
        add_bool(tag, value)
      when Float
        add_double(tag, value)
      else
        add_string(tag, value)
      end

      self
    end

    # Adds a (tag, integer value) pair to the CMF message.
    #
    # @param tag [Integer,Object] Must be an integer or a key in the dictionary.
    # @param value [Integer,Object] An integer value. Non-integer values will be
    #     converted to integers by calling the `to_i` method on them.
    # @return [Builder] self
    def add_int(tag, value)
      value = value.to_i
      type = Type::POSITIVE_NUMBER
      if value < 0
        type = Type::NEGATIVE_NUMBER
        value *= -1
      end

      write_tag(tag, type)
      Varint.serialize(@io, value.abs)

      self
    end

    # Adds a (tag, string value) pair to the CMF message.
    #
    # @param tag [Integer,Object] Must be an integer or a key in the dictionary.
    # @param value [String,Object] A string value. Non-string values will be
    #     converted to strings by calling the `to_s` method on them.
    # @return [Builder] self
    def add_string(tag, value)
      value = value.to_s
      write_tag(tag, Type::STRING)
      Varint.serialize(@io, value.bytesize)
      @io << value

      self
    end

    # Adds a (tag, byte_array value) pair to the CMF message.
    #
    # @param tag [Integer,Object] Must be an integer or a key in the dictionary.
    # @param value [String,Object] A string value. Non-string values will be
    #     converted to strings by calling the `to_s` method on them.
    # @return [Builder] self
    def add_bytes(tag, value)
      value = value.to_s
      write_tag(tag, Type::BYTE_ARRAY)
      Varint.serialize(@io, value.bytesize)
      @io << value

      self
    end

    # Adds a (tag, boolean value) pair to the CMF message.
    #
    # @param tag [Integer,Object] Must be an integer or a key in the dictionary.
    # @param value [Boolean,Object] A boolean value. Non-boolean values will be
    #     converted to boolean by testing their truthiness.
    # @return [Builder] self
    def add_bool(tag, value)
      write_tag(tag, value ? Type::BOOL_TRUE : Type::BOOL_FALSE)

      self
    end

    # Adds a (tag, float value) pair to the CMF message.
    #
    # @param tag [Integer,Object] Must be an integer or a key in the dictionary.
    # @param value [Float,Object] A float value. Non-float values will be
    #     converted to floats by calling the `to_f` method on them.
    # @return [Builder] self
    def add_double(tag, value)
      write_tag(tag, Type::DOUBLE)
      @io << [value.to_f].pack('E')

      self
    end
    alias_method :add_float, :add_double

    # @return [String] An octet string, each character representing one byte
    #     of the CMF message.
    def to_octet
      @io.string
    end

    # @return [String] A hex string, every 2 characters representing one byte
    #     of the CMF message.
    def to_hex
      to_octet.unpack('H*').first
    end

    private

    def write_tag(tag, type)
      if !tag.is_a?(Integer)
        @dictionary[tag] or raise ArgumentError, "Tag '#{tag}' not found in dictionary"
        tag = @dictionary[tag]
      end
      tag >= 0 or raise ArgumentError, "Invalid tag value #{tag}. Must be >= 0"
      (type >= 0 && type <= 6) or raise ArgumentError, "Invalid type"

      if tag >= 31
        @io.putc(type | 0xF8)
        Varint.serialize(@io, tag)
      else
        @io.putc((tag << 3) + type)
      end
    end
  end
end
