module LZString
  # Module for Uint8Array encoding/decoding
  module Uint8Array
    # Compress a string to a Uint8Array
    # @param [String] input String to compress
    # @return [Array<Integer>] Array of 8-bit integers
    def self.compress_to_uint8_array(input)
      return [] if input.nil? || input.empty?

      # Compress the string
      compressed = LZString.compress(input)
      return [] if compressed.nil? || compressed.empty?

      # Calculate buffer length
      buf_len = compressed.length * 2

      # Create the result array
      result = Array.new(buf_len, 0)

      # Convert the compressed string to an array of bytes
      compressed.each_char.with_index do |char, i|
        code = char.ord
        result[i * 2] = (code >> 8) & 0xFF # High byte
        result[(i * 2) + 1] = code & 0xFF # Low byte
      end

      result
    end

    # Convert a Uint8Array to a string
    # @param [Array<Integer>] uint8array Array of 8-bit integers
    # @param [Boolean] legacy Whether to use legacy mode (requires even length)
    # @return [String] String representation of the Uint8Array
    def self.convert_from_uint8_array(uint8array, legacy = false)
      return "" if uint8array.nil? || uint8array.empty?

      # Ensure the array has an even length for legacy mode
      if legacy && uint8array.length.odd?
        return nil # Legacy mode requires even length
      end

      # Use original length for modern mode, ensure even length for legacy mode
      length = if legacy
                 uint8array.length
               else
                 uint8array.length.even? ? uint8array.length : uint8array.length - 1
               end

      # Combine pairs of bytes to form characters
      result = ""
      i = 0
      while i < length
        begin
          high_byte = uint8array[i] || 0
          low_byte = uint8array[i + 1] || 0
          value = (high_byte << 8) | low_byte

          # Convert to character with error handling
          begin
            result += begin
              value.chr(Encoding::UTF_8)
            rescue
              (value % 256).chr(Encoding::UTF_8)
            end
          rescue
            "?"
          end

          i += 2
        rescue
          # Skip problematic pairs
          i += 2
        end
      end

      result
    end

    # Convert a string to a Uint8Array
    # @param [String] string String to convert
    # @param [Boolean] _legacy Option for compatibility with legacy mode (unused)
    # @return [Array<Integer>] Array of 8-bit integers
    def self.convert_to_uint8_array(string, _legacy = false)
      return [] if string.nil? || string.empty?

      # Ensure the string has proper encoding
      string = string.dup.force_encoding(Encoding::UTF_8)

      # Create the result array
      result = Array.new(string.length * 2, 0)

      # Convert each character to a pair of bytes
      string.each_char.with_index do |char, i|
        code = char.ord
        result[i * 2] = (code >> 8) & 0xFF # High byte
        result[(i * 2) + 1] = code & 0xFF # Low byte
      rescue
        # Use fallback for problematic characters
        result[i * 2] = 0
        result[(i * 2) + 1] = "?".ord
      end

      result
    end

    # Decompress a Uint8Array to a string
    # @param [Array<Integer>] uint8array Array of 8-bit integers
    # @param [Boolean] legacy Whether to use legacy mode
    # @return [String, nil] Decompressed string or nil if decompression fails
    def self.decompress_from_uint8_array(uint8array, legacy = false)
      return "" if uint8array.nil? || uint8array.empty?

      # Ensure all array elements are valid bytes
      uint8array = uint8array.map { |byte| byte.is_a?(Integer) ? byte & 0xFF : 0 }

      # Check for even length in legacy mode
      return nil if legacy && uint8array.length.odd?

      begin
        # Convert Uint8Array to string format first
        compressed = convert_from_uint8_array(uint8array, legacy)
        return nil if compressed.nil? || compressed.empty?

        # Then decompress
        LZString.decompress(compressed)
      rescue
        nil
      end
    end
  end

  # Make module methods available at the class level
  # Compress a string to Uint8Array format
  # @param [String] input String to compress
  # @return [Array<Integer>] Array of 8-bit integers
  def self.compress_to_uint8_array(input)
    Uint8Array.compress_to_uint8_array(input)
  end

  # Decompress a Uint8Array to a string
  # @param [Array<Integer>] uint8array Array of 8-bit integers
  # @param [Boolean] legacy Whether to use legacy mode
  # @return [String, nil] Decompressed string or nil if decompression fails
  def self.decompress_from_uint8_array(uint8array, legacy = false)
    Uint8Array.decompress_from_uint8_array(uint8array, legacy)
  end

  # Convert a string to a Uint8Array
  # @param [String] string String to convert
  # @param [Boolean] legacy Whether to use legacy mode
  # @return [Array<Integer>] Array of 8-bit integers
  def self.convert_to_uint8_array(string, legacy = false)
    Uint8Array.convert_to_uint8_array(string, legacy)
  end

  # Convert a Uint8Array to a string
  # @param [Array<Integer>] uint8array Array of 8-bit integers
  # @param [Boolean] legacy Whether to use legacy mode
  # @return [String] String representation of the Uint8Array
  def self.convert_from_uint8_array(uint8array, legacy = false)
    Uint8Array.convert_from_uint8_array(uint8array, legacy)
  end
end
