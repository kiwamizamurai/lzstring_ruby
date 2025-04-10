module LZString
  # Module for base64 encoding/decoding
  module Base64
    # Compress a string to base64 encoding
    # @param [String] input String to compress
    # @return [String] Base64 compressed string
    def self.compress_to_base64(input)
      return "" if input.nil? || input.empty?

      begin
        # Force input to UTF-8 encoding
        input = input.to_s.dup.force_encoding(Encoding::UTF_8)

        # Use the _compress function with Base64 parameters
        result = LZString._compress(input, 6) do |a|
          key_str_base64[a % key_str_base64.length]
        end

        # Handle padding for Base64
        case result.length % 4
        when 0
          result
        when 1
          "#{result}==="
        when 2
          "#{result}=="
        when 3
          "#{result}="
        end
      rescue
        # Log error and return empty string on failure
        # STDERR.puts "Base64 compression error: #{e.message}"
        ""
      end
    end

    # Decompress a string from base64 encoding
    # @param [String] input Base64 compressed string
    # @return [String, nil] Decompressed string or nil if decompression fails
    def self.decompress_from_base64(input)
      return "" if input.nil? || input.empty?

      begin
        # Ensure input is properly encoded
        input = input.to_s.dup.force_encoding(Encoding::UTF_8)

        # Use the _decompress function with Base64 parameters
        result = LZString._decompress(input.length, 32) do |index|
          if index >= input.length
            0
          else
            get_base_value(key_str_base64, input[index])
          end
        end

        # Ensure proper UTF-8 encoding of the result
        if result.is_a?(String)
          # Force UTF-8 encoding and replace invalid bytes
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
        # Log error and return nil on failure
        # STDERR.puts "Base64 decompression error: #{e.message}"
        nil
      end
    end

    # Map of Base64 characters for compression
    def self.key_str_base64
      "ABCDEFGHIJKLMNOPQRSTUVWXYZabcdefghijklmnopqrstuvwxyz0123456789+/="
    end

    # Get base value for a character using lookup string
    # @param [String] alphabet Lookup string for value mapping
    # @param [String] character Character to look up
    # @return [Integer] Value for the character
    def self.get_base_value(alphabet, character)
      alphabet.index(character) || 0
    end
  end

  # Make module methods available at the class level
  # Compress a string to base64 encoding
  # @param [String] input String to compress
  # @return [String] Base64 compressed string
  def self.compress_to_base64(input)
    Base64.compress_to_base64(input)
  end

  # Decompress a string from base64 encoding
  # @param [String] input Base64 compressed string
  # @return [String, nil] Decompressed string or nil if decompression fails
  def self.decompress_from_base64(input)
    Base64.decompress_from_base64(input)
  end
end
