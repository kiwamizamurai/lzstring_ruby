module LZString
  # Module for URI encoding/decoding
  module URI
    # Compress a string to uri encoding
    # @param [String] input String to compress
    # @return [String] URI encoded compressed string
    def self.compress_to_encoded_uri_component(input)
      return "" if input.nil? || input.empty?

      begin
        # Force input to UTF-8 encoding
        input = input.to_s.dup.force_encoding(Encoding::UTF_8)

        # Get the keyStr for URI component encoding
        keyStr = key_str_uri_safe

        # Use the _compress function with URI parameters
        LZString._compress(input, 6) do |a|
          keyStr[a]
        end
      rescue
        # Log error and return empty string on failure
        # STDERR.puts "URI compression error: #{e.message}"
        ""
      end
    end

    # Decompress a string from uri encoding
    # @param [String] input URI encoded compressed string
    # @return [String, nil] Decompressed string or nil if decompression fails
    def self.decompress_from_encoded_uri_component(input)
      return "" if input.nil? || input.empty?

      begin
        # Ensure input is properly encoded
        input = input.to_s.dup.force_encoding(Encoding::UTF_8)

        # Replace spaces with plus signs (if needed)
        input = input.gsub(" ", "+") if input.include?(" ")

        # Get the keyStr for URI component encoding
        keyStr = key_str_uri_safe

        # Use the _decompress function with URI parameters
        LZString._decompress(input.length, 32) do |index|
          if index >= input.length
            0
          else
            get_base_value(keyStr, input[index])
          end
        end
      rescue
        # Log error and return nil on failure
        # STDERR.puts "URI decompression error: #{e.message}"
        nil
      end
    end

    # Get the key string for URI safe encoding
    # @return [String] URI safe key string
    def self.key_str_uri_safe
      "ABCDEFGHIJKLMNOPQRSTUVWXYZabcdefghijklmnopqrstuvwxyz0123456789+-$"
    end

    # Get the base value for a character
    # @param [String] alphabet The alphabet string to use
    # @param [String] character The character to get the base value for
    # @return [Integer] The base value
    def self.get_base_value(alphabet, character)
      alphabet.index(character) || 0
    end
  end

  # Make module methods available at the class level
  # Compress a string to URI-component safe encoding
  # @param [String] input String to compress
  # @return [String] URI-component safe compressed string
  def self.compress_to_encoded_uri_component(input)
    URI.compress_to_encoded_uri_component(input)
  end

  # Decompress a string from URI-component safe encoding
  # @param [String] input URI-component safe compressed string
  # @return [String, nil] Decompressed string or nil if decompression fails
  def self.decompress_from_encoded_uri_component(input)
    URI.decompress_from_encoded_uri_component(input)
  end

  # Keep backward compatibility with camelCase methods
  class << self
    alias compressToEncodedURIComponent compress_to_encoded_uri_component
    alias decompressFromEncodedURIComponent decompress_from_encoded_uri_component
  end
end
