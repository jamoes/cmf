Change log
====

This gem follows [Semantic Versioning 2.0.0](http://semver.org/spec/v2.0.0.html).
All classes and public methods are part of the public API.

1.0.0
----
Released on 2018-04-10

All core functionality is implemented:

- `CMF` module methods:
  - `CMF.build`
  - `CMF.build_hex`
  - `CMF.parse`
  - `CMF.parse_hex`
- `CMF::Builder` class, with the following methods:
  - `add`
  - `add_bool`
  - `add_bytes`
  - `add_double` (also aliased as `add_float`)
  - `add_int`
  - `add_string`
  - `reset`
  - `to_hex`
  - `to_octet`
  - `dictionary` read-only attribute
- `CMF::Parser` class, with the following methods:
  - `each`
  - `message=`
  - `message_hex=`
  - `next_pair`
  - `parse`
  - `parse_hex`
  - `inverted_dictionary` read-only attribute
- `CMF::Varint` class, with the following methods:
  - `deserialize`
  - `serialize`
- `CMF::Dictionary.validate` helper method
- `CMF::Type` constants
- `MalformedMessageError` class
