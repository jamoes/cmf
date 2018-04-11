# CMF

[![Build Status](https://travis-ci.org/jamoes/cmf.svg?branch=master)](https://travis-ci.org/jamoes/cmf)

## Description

This library builds and parses messages in the [Compact Message Format (CMF)](http://flowee.org/docs/api/protocol-spec/).

CMF is a binary format that has the speed and compact size of a binary format combined with the provably correct markup and type-safety of formats like XML and JSON.

A CMF message is a flat list of tokens. Each token is comprised of 3 elements: a tag name, a type, and a value. Tag names are written to the message as numbers, so an external schema dictionary is typically used to map the tag numbers to names.

Each CMF token is completely self-contained. Even a reader that doesn't know the schema of the message it is parsing can still extract all tokens from the message. This makes the format exceptionally useful for extensibility because a reader can just skip over unknown tokens.

## Installation

This library is distributed as a gem named [cmf](https://rubygems.org/gems/cmf)
at RubyGems.org.  To install it, run:

    gem install cmf

## Usage

First, require the gem:

```ruby
require 'cmf'
```

Next, we'll build and parse a simple message with two tokens. The message will contain the string `"Proxima Centauri"`, associated with the tag `0`, and the floating point number `4.2421` associated with the tag `1`.

```ruby
message = CMF.build({0 => "Proxima Centauri", 1 => 4.2421})
# => "\x02\x10Proxima Centauri\x0EGr\xF9\x0F\xE9\xF7\x10@"

CMF.parse(message)
# => {0=>"Proxima Centauri", 1=>4.2421}
```

Rather than using the tags `0`, and `1`, we can define a schema dictionary which maps human-readable names to tag numbers.

```ruby
dictionary = {star: 0, distance: 1}
message = CMF.build({star: "Proxima Centauri", distance: 4.2421}, dictionary)
# => "\x02\x10Proxima Centauri\x0EGr\xF9\x0F\xE9\xF7\x10@"

CMF.parse(message, dictionary)
# => {:star=>"Proxima Centauri", :distance=>4.2421}
```

For more flexibility in parsing and building messages, you can use the `CMF::Builder` and `CMF::Parser` classes.

```ruby
builder = CMF::Builder.new(dictionary)
builder.add(:star, "Proxima Centauri")
builder.add(:distance, 4.2421)
message = builder.to_octet

parser = CMF::Parser.new(dictionary)
parser.message = message
parser.next_pair # => [:star, "Proxima Centauri"]
parser.next_pair # => [:distance, 4.2421]
parser.next_pair # => nil

parser.message = message     ##
parser.each do |tag, value|  # star: Proxima Centauri
  puts "#{tag}: #{value}"    # distance: 4.2421
end                          ##
```
## Supported platforms

Ruby 2.0 and above, including jruby.

## Documentation

For complete documentation, see the [CMF page on RubyDoc.info](http://rubydoc.info/gems/cmf).
