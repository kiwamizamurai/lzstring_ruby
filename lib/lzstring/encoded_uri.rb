module LZString
  # Module for URI encoding/decoding
  module EncodedURI
    # Key string for URI encoding
    KEY_STR_URI_SAFE = "ABCDEFGHIJKLMNOPQRSTUVWXYZabcdefghijklmnopqrstuvwxyz0123456789+-$".freeze

    # Compress a string to URI encoding
    # @param [String] input String to compress
    # @return [String] URI encoded compressed string
    def self.compress_to_encoded_uri_component(input)
      return "" if input.nil? || input.empty?

      begin
        # Force input to UTF-8 encoding
        input = input.to_s.dup.force_encoding(Encoding::UTF_8)

        # Use the _compress function with URI parameters
        LZString._compress(input, 6) do |a|
          KEY_STR_URI_SAFE[a % KEY_STR_URI_SAFE.length]
        end
      rescue
        # Log error and return empty string on failure
        # STDERR.puts "URI compression error: #{e.message}"
        ""
      end
    end

    # Decompress a string from URI encoding
    # @param [String] input URI encoded compressed string
    # @return [String, nil] Decompressed string or nil if decompression fails
    def self.decompress_from_encoded_uri_component(input)
      return "" if input.nil? || input.empty?

      begin
        # Ensure input is properly encoded
        input = input.to_s.dup.force_encoding(Encoding::UTF_8)

        # Replace spaces with plus signs
        input = input.gsub(" ", "+")

        # Initialize reverse dictionary
        reverse_dict = {}
        KEY_STR_URI_SAFE.each_char.with_index { |c, i| reverse_dict[c] = i }

        # Use the _decompress function with URI parameters
        result = LZString._decompress(input.length, 32) do |index|
          if index >= input.length
            0
          else
            # Get character value from dictionary or return 0
            reverse_dict[input[index]] || 0
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
        # STDERR.puts "URI decompression error: #{e.message}"
        nil
      end
    end
  end

  # Make module methods available at the class level
  def self.compress_to_encoded_uri_component(input)
    EncodedURI.compress_to_encoded_uri_component(input)
  end

  def self.decompress_from_encoded_uri_component(input)
    EncodedURI.decompress_from_encoded_uri_component(input)
  end
end
