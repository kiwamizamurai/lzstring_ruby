module LZString
  # Module for custom encoding/decoding
  module Custom
    # Compress a string to custom encoding
    # @param [String] input String to compress
    # @param [String] key_str Custom key string for compression
    # @return [String] Compressed string with custom encoding
    def self.compress_to_custom(input, key_str)
      return "" if input.nil? || input.empty? || key_str.nil? || key_str.empty?

      begin
        # Force input to UTF-8 encoding
        input = input.to_s.dup.force_encoding(Encoding::UTF_8)
        key_str = key_str.to_s.dup.force_encoding(Encoding::UTF_8)

        # Validate key string length
        raise ArgumentError, "Custom key string must have at least 2 characters" if key_str.length < 2

        res_str = ""
        val = 0
        c = 0

        # Use the _compress function with custom parameters
        LZString._compress(input, 6) do |a|
          val = (val << 6) | a
          c += 6

          while c >= 6
            c -= 6
            index = (val >> c) & 63
            res_str += begin
              key_str[index].chr
            rescue
              "?"
            end
          end

          a
        end

        # Handle remaining bits
        if c.positive?
          res_str += begin
            key_str[((val << 6) >> c) & 63].chr
          rescue
            "?"
          end
        end

        res_str
      rescue
        # Log error and return empty string on failure
        # STDERR.puts "Custom compression error: #{e.message}"
        ""
      end
    end

    # Decompress a string from custom encoding
    # @param [String] input Compressed string with custom encoding
    # @param [String] key_str Custom key string used for compression
    # @return [String, nil] Decompressed string or nil if decompression fails
    def self.decompress_from_custom(input, key_str)
      return "" if input.nil? || input.empty? || key_str.nil? || key_str.empty?

      begin
        # Force input to UTF-8 encoding
        input = input.to_s.dup.force_encoding(Encoding::UTF_8)
        key_str = key_str.to_s.dup.force_encoding(Encoding::UTF_8)

        # Validate key string length
        raise ArgumentError, "Custom key string must have at least 2 characters" if key_str.length < 2

        # Create a reverse mapping for the key string
        reverse_dict = {}
        key_str.chars.each_with_index do |char, index|
          reverse_dict[char] = index
        end

        # Use the _decompress function with custom parameters
        result = LZString._decompress(input.length, 32) do |index|
          if index >= input.length
            0
          else
            char = input[index]
            if reverse_dict.key?(char)
              reverse_dict[char]
            else
              0 # Use 0 for characters not in the key string
            end
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
        # STDERR.puts "Custom decompression error: #{e.message}"
        nil
      end
    end
  end

  # Make module methods available at the class level
  # Compress a string using a custom character set
  # @param [String] input String to compress
  # @param [String] key_str Custom character set to use for encoding
  # @return [String] Compressed string using custom encoding
  def self.compress_to_custom(input, key_str)
    Custom.compress_to_custom(input, key_str)
  end

  # Decompress a string using a custom character set
  # @param [String] input Compressed string using custom encoding
  # @param [String] key_str Custom character set used for encoding
  # @return [String, nil] Decompressed string or nil if decompression fails
  def self.decompress_from_custom(input, key_str)
    Custom.decompress_from_custom(input, key_str)
  end
end
