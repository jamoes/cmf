require 'cmf/builder.rb'
require 'cmf/dictionary.rb'
require 'cmf/malformed_message_error.rb'
require 'cmf/parser.rb'
require 'cmf/type.rb'
require 'cmf/varint.rb'
require 'cmf/version.rb'

# The top-level module for the cmf gem.
module CMF
  # Builds a CMF message from an object.
  #
  # @param obj [Hash,#each] The object to be built into a CMF message. Can be
  #     a hash, or any object that responds to `.each` and yields (tag, value)
  #     pairs.
  # @param dictionary [Hash,Array] Optional. The dictionary mapping tag
    #     names to numbers. See {Dictionary.validate}.
  # @return [String] An octet string, each character representing one byte of
  #     the CMF message.
  def self.build(obj, dictionary = nil)
    Builder.new(dictionary).build(obj).to_octet
  end

  # Builds hex-encoded a CMF message from an object.
  #
  # @see #CMF.build
  # @return [String] A hex string, every 2 characters representing one byte of
  #     the CMF message.
  def self.build_hex(obj, dictionary = nil)
    Builder.new(dictionary).build(obj).to_hex
  end

  # Parses a CMF message into an object.
  #
  # @param message [String] A CMF message.
  # @return [Hash] See {Parser.parse}.
  def self.parse(message, dictionary = nil)
    Parser.new(dictionary).parse(message)
  end

  # Parses a hex-encoded CMF message into an object.
  #
  # @param message_hex [String] A hex-encoded CMF message.
  # @return [Hash] See {Parser.parse}.
  def self.parse_hex(message_hex, dictionary = nil)
    Parser.new(dictionary).parse_hex(message_hex)
  end
end
