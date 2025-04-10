require "lzstring/version"
require "lzstring/compress"
require "lzstring/decompress"
require "lzstring/base64"
require "lzstring/encoded_uri"
require "lzstring/utf16"
require "lzstring/uint8_array"
require "lzstring/custom"

# LZString is a Ruby implementation of the lz-string JavaScript library
# for string compression and decompression.
module LZString
  # Custom error class for LZString errors
  class Error < StandardError; end

  # Standard compression using raw format
  # @param [String] input String to compress
  # @return [String] Compressed string
  def self.compress(input)
    return "" if input.nil? || input.empty?

    begin
      # Ensure UTF-8 encoding
      input = input.to_s.dup.force_encoding(Encoding::UTF_8)

      # Use 16 bits per character for output
      _compress(input, 16) do |code|
        # Convert integer code to character with fallback for invalid codes

        if code.between?(0, 0x10FFFF)
          code.chr(Encoding::UTF_8)
        else
          # Fallback for invalid code points
          "?"
        end
      rescue RangeError, ArgumentError
        # Fallback to safe character if we can't represent this code point
        "?"
      end
    rescue
      # Return empty string on error, matching JavaScript's behavior
      ""
    end
  end

  # Standard decompression using raw format
  # @param [String] compressed_str Compressed string
  # @return [String, nil] Decompressed string or nil if decompression fails
  def self.decompress(compressed_str)
    return "" if compressed_str.nil?
    return "" if compressed_str.empty?

    begin
      # Ensure the input is properly encoded
      input = compressed_str.to_s.dup.force_encoding(Encoding::UTF_8)

      # Use 32768 as the reset value, same as JavaScript
      result = _decompress(input.length, 32_768) do |index|
        if index < input.length
          # Get the code point value of the character
          input[index].ord
        else
          0
        end
      end

      # Ensure proper UTF-8 encoding of the result
      if result.is_a?(String)
        # Force UTF-8 encoding
        result.force_encoding(Encoding::UTF_8)

        # Check if the result is valid UTF-8, if not try to repair
        unless result.valid_encoding?
          # Replace invalid sequences with a replacement character
          result = result.encode(Encoding::UTF_8,
                                 Encoding::UTF_8,
                                 invalid: :replace,
                                 undef: :replace,
                                 replace: "?")
        end

      end
      result
    rescue
      # Return nil on error, matching JavaScript's behavior
      nil
    end
  end

  # Include other public methods from modules
  include Base64
  include EncodedURI
  include UTF16
  include Uint8Array
  include Custom
end
