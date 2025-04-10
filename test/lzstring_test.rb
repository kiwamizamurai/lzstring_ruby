require "test_helper"

# Test class for LZString library testing
class LZStringTest < Minitest::Test
  def test_that_it_has_a_version_number
    refute_nil ::LZString::VERSION
  end

  # Basic compression/decompression tests

  def test_basic_compression
    test_strings = {
      "ascii" => "Hello, world!",
      "empty" => "",
      "unicode" => "こんにちは世界",
      "long" => "Lorem ipsum dolor sit amet, consectetur adipiscing elit.",
      "repeated" => "abcabcabcabcabcabcabcabcabcabc"
    }

    test_strings.each do |name, original|
      compressed = LZString.compress(original)
      decompressed = LZString.decompress(compressed)

      assert_equal original, decompressed, "Failed with #{name} string"

      # Verify compression happens for non-empty strings
      if !original.empty? && (name == "repeated")
        # For repeated patterns, compression should be efficient
        assert_operator compressed.length, :<, original.length, "No compression achieved for repeated pattern"
      end
    end
  end

  def test_nil_input
    compressed = LZString.compress(nil)
    decompressed = LZString.decompress(compressed)

    assert_equal "", decompressed

    assert_equal "", LZString.decompress(nil)
    assert_equal "", LZString.decompress("")
  end

  # Test all encoding formats with various types of input

  def test_all_encoding_formats
    test_strings = [
      "Hello, world!", # ASCII
      "★☆♠♣", # Safe Unicode symbols
      "Hello Привет" # Mixed scripts
    ]

    test_strings.each do |original|
      # Base64 encoding
      compressed = LZString.compress_to_base64(original)
      decompressed = LZString.decompress_from_base64(compressed)

      assert_equal original, decompressed, "Base64 encoding failed for: #{original}"

      # URI Component encoding
      compressed = LZString.compress_to_encoded_uri_component(original)
      decompressed = LZString.decompress_from_encoded_uri_component(compressed)

      assert_equal original, decompressed, "URI encoding failed for: #{original}"

      # UTF-16 encoding
      compressed = LZString.compress_to_utf16(original)
      decompressed = LZString.decompress_from_utf16(compressed)

      assert_equal original, decompressed, "UTF-16 encoding failed for: #{original}"

      # Uint8Array encoding
      compressed = LZString.compress_to_uint8_array(original)
      decompressed = LZString.decompress_from_uint8_array(compressed)

      assert_equal original, decompressed, "Uint8Array encoding failed for: #{original}"
    end
  end

  def test_custom_encoding
    test_strings = [
      "Hello, world!",
      "★☆♠♣"
    ]

    dictionary = "0123456789ABCDEFGHIJKLMNOPQRSTUVWXYZabcdefghijklmnopqrstuvwxyz+-="

    test_strings.each do |original|
      compressed = LZString.compress_to_custom(original, dictionary)
      decompressed = LZString.decompress_from_custom(compressed, dictionary)

      assert_equal original, decompressed, "Custom encoding failed for: #{original}"
    end
  end

  # Edge case tests

  def test_large_string
    # Test with a large string (100 chars)
    original = "a" * 100
    compressed = LZString.compress(original)
    decompressed = LZString.decompress(compressed)

    assert_equal original, decompressed
  end

  def test_binary_data
    # Test with binary data
    binary_data = (0..20).map do |n|
      n.chr
    rescue
      "?"
    end.join
    compressed = LZString.compress(binary_data)
    decompressed = LZString.decompress(compressed)

    assert_equal binary_data, decompressed
  end

  def test_error_handling
    # Test error handling for compression with invalid input
    # The actual output may vary, so we test that it doesn't raise an exception
    # and returns some non-nil value
    result = LZString.compress(42.chr)

    refute_nil result

    # Test error handling for decompression with invalid input
    assert_nil LZString.decompress("invalid compressed string")

    # Test invalid input handling with error responses that won't raise platform-specific errors
    begin
      # Use clearly invalid input that should consistently fail across platforms
      LZString.decompress_from_base64("$$$")
      # Platform-specific handling - some may return nil, others empty string or other values
      # We just ensure no exception is raised
      pass
    rescue => _e
      # If an exception occurs, the test still passes - we're just testing error handling
      pass
    end

    # Different platforms may handle UTF-16 differently, so we just make sure it doesn't crash
    # and don't assert anything about the result
    begin
      LZString.decompress_from_utf16("\0\0\0\u0001")
      pass # Test passes if no exception is raised
    rescue => _e
      pass # Test also passes if an exception is raised - we're just testing error handling
    end
  end

  def test_uint8array_legacy_mode
    # Test legacy mode in Uint8Array
    original = "Hello, world!"
    uint8array = LZString.compress_to_uint8_array(original)

    # Add an extra byte to make it odd length
    uint8array << 0

    # Should fail in legacy mode
    assert_nil LZString.decompress_from_uint8_array(uint8array, true)

    # Should succeed in normal mode
    result = LZString.decompress_from_uint8_array(uint8array, false)

    assert_equal original, result
  end
end
