# LZString Ruby

[![Gem Version](https://badge.fury.io/rb/lzstring-ruby.svg)](https://badge.fury.io/rb/lzstring-ruby)
[![Build Status](https://github.com/kiwamizamurai/lzstring_ruby/workflows/Ruby/badge.svg)](https://github.com/kiwamizamurai/lzstring-ruby/actions)
[![Coverage Status](https://img.shields.io/badge/coverage-100%25-brightgreen.svg)](https://github.com/kiwamizamurai/lzstring-ruby)
[![License: MIT](https://img.shields.io/badge/License-MIT-yellow.svg)](https://opensource.org/licenses/MIT)

A Ruby port of lz-string - a string compression algorithm with support for multiple encodings (base64, URI, UTF16) and seamless JavaScript interoperability

## Installation

Add this line to your application's Gemfile:

```ruby
gem 'lzstring'
```

And then execute:

```bash
$ bundle install
```

Or install it directly:

```bash
$ gem install lzstring
```

## Usage

### Basic Compression/Decompression

```ruby
require 'lzstring'

# Standard compression
compressed = LZString.compress("Hello, world!")
decompressed = LZString.decompress(compressed)
puts decompressed # => "Hello, world!"

# Base64 compression
base64 = LZString.compress_to_base64("Hello, world!")
original = LZString.decompress_from_base64(base64)
puts original # => "Hello, world!"

# URI-safe compression
uri_safe = LZString.compress_to_encoded_uri_component("Hello, world!")
original = LZString.decompress_from_encoded_uri_component(uri_safe)
puts original # => "Hello, world!"

# UTF16 compression
utf16 = LZString.compress_to_utf16("Hello, world!")
original = LZString.decompress_from_utf16(utf16)
puts original # => "Hello, world!"

# Uint8Array compression
uint8 = LZString.compress_to_uint8_array("Hello, world!")
original = LZString.decompress_from_uint8_array(uint8)
puts original # => "Hello, world!"
```

### Custom Encoder

```ruby
require 'lzstring'

dictionary = "0123456789ABCDEFGHIJKLMNOPQRSTUVWXYZabcdefghijklmnopqrstuvwxyz+-="
custom_compressed = LZString.compress_to_custom("Hello, world!", dictionary)
original = LZString.decompress_from_custom(custom_compressed, dictionary)
puts original # => "Hello, world!"
```

## Command Line Interface

The gem includes a command-line tool for compressing and decompressing files:

```bash
# Compress a file
$ lzstring input.txt > output.txt

# Decompress a file
$ lzstring -d input.txt > output.txt

# Compress with base64 encoding
$ lzstring -e base64 input.txt > output.txt

# Decompress from base64 encoding
$ lzstring -d -e base64 input.txt > output.txt

# Save to output file
$ lzstring -o output.txt input.txt

# Get help
$ lzstring -h
```

### CLI Options

```
Usage: lzstring [options] [input-file]

Use lz-string to compress or decompress a file

Arguments:
  input-file                  file to process, if no file then read from stdin

Options:
  -V, --version               output the version number
  -d, --decompress            if unset then this will compress
  -e, --encoder <type>        character encoding to use (choices: "base64", "encodeduri", "raw", "uint8array", "utf16", default: "raw")
  -o, --output <output-file>  output file, otherwise write to stdout
  -q, --quiet                 don't print any error messages
  -h, --help                  display help for command
```

## Implementation Notes

This Ruby implementation closely follows the original JavaScript lz-string library, with a few important notes:

### Character Encoding

Ruby handles character encoding differently from JavaScript. This implementation uses UTF-8 encoding for all string operations to ensure compatibility with the JavaScript version. The library includes special handling for multibyte characters, ensuring proper UTF-8 encoding throughout the compression and decompression process.

### Unicode Support

The implementation supports basic Unicode characters and includes robust error handling for edge cases. Due to differences in how Ruby and JavaScript handle character encodings, some complex Unicode characters might not compress/decompress perfectly.

### Error Handling

When decompression fails:
- This library returns `nil` for invalid inputs, similar to the JavaScript version
- For partial or corrupted compression data, the result will be `nil` rather than a partial string
- The implementation includes thorough error handling to prevent crashes

### Performance Considerations

The Ruby implementation is a direct port of the JavaScript algorithm and optimized for correctness rather than performance. For very large strings (> 1MB), performance may be noticeably slower than the JavaScript version.

## Compatibility

This gem is designed to be compatible with the original JavaScript [lz-string](https://github.com/pieroxy/lz-string) library. It can decompress data compressed by the JavaScript library and vice versa.

Example of cross-platform usage:

```javascript
// JavaScript
const compressed = LZString.compressToBase64('Hello, world!');
// Pass this compressed string to your Ruby application
```

```ruby
# Ruby
original = LZString.decompress_from_base64(compressed_from_js)
puts original # => "Hello, world!"
```

## Implementation Details

This Ruby implementation follows the same LZ-based compression algorithm as the original JavaScript library. Key features:

- Efficient string compression algorithm
- Multiple encoding formats (raw, base64, URI component, UTF16, Uint8Array)
- Custom dictionary support
- Unicode character support
- Robust error handling

### Test Status

All tests are now passing! The library includes comprehensive tests for:
- Basic compression/decompression
- Various encoding formats (Base64, URI, UTF16, Uint8Array)
- Unicode character support
- Edge cases (large strings, repeated patterns, binary data)
- Error handling

You can run the tests with:

```bash
$ bundle exec rake test
```

## Development

After checking out the repo, run `bin/setup` to install dependencies. Then, run `rake quality` to run the tests, RuboCop checks, and YARD documentation generation.

To install this gem onto your local machine, run `bundle exec rake install`. To release a new version, update the version number in `version.rb`, and then run `bundle exec rake release`, which will create a git tag for the version, push git commits and tags, and push the `.gem` file to [rubygems.org](https://rubygems.org).

## Code Quality

The codebase is fully covered by:
- Comprehensive test suite with 100% coverage
- RuboCop for style checking
- YARD for documentation

Run all quality checks:

```bash
$ bundle exec rake quality
```

## License

The gem is available as open source under the terms of the [MIT License](https://opensource.org/licenses/MIT).

## Related Projects

This gem is a Ruby port of the JavaScript [lz-string](https://github.com/pieroxy/lz-string) library by Pieroxy.

Other language ports:
- **Java:** [lzstring4j](https://github.com/rufushuang/lz-string4java)
- **Python:** [lz-string-python](https://github.com/eduardtomasek/lz-string-python)
- **C#:** [lz-string-csharp](https://github.com/kreudom/lz-string-csharp)
- **PHP:** [lz-string-php](https://github.com/nullpunkt/lz-string-php)
- **Go:** [go-lz-string](https://github.com/daku10/go-lz-string)
