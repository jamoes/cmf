module CMF

  # Defines the enum value for all types that can be stored in a CMF message.
  module Type
    # Varint encoded integer.
    POSITIVE_NUMBER = 0

    # The value is multiplied by -1 and then serialized in the same manner
    # as a POSITIVE_NUMBER.
    NEGATIVE_NUMBER = 1

    # Varint length (in bytes) first, then the UTF-8 encoded string.
    STRING          = 2

    # Varint length (in bytes) first, then the binary encoded string.
    BYTE_ARRAY      = 3

    # True value, no additional data stored.
    BOOL_TRUE       = 4

    # False value, no additional data stored.
    BOOL_FALSE      = 5

    # Double-precision (8 bytes) little-endian floating-point number.
    DOUBLE          = 6
  end
end
