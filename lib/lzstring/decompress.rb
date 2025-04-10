module LZString
  # Internal method for decompression
  # @param [Integer] length The length of compressed string
  # @param [Integer] reset_value The buffer size used for decompression
  # @param [Block] get_next_value Block that returns character code of character at given position
  # @return [String] Decompressed string
  def self._decompress(length, reset_value, &get_next_value)
    return "" if length.zero?

    begin
      dictionary = {}
      enlarge_in = 4
      dict_size = 4
      num_bits = 3
      entry = ""
      result = []

      # Initialize dictionary with first 3 entries
      3.times do |i|
        dictionary[i] = i.to_s
      end

      # Feed bits in, 1 at a time
      data_val = get_next_value.call(0)
      data_position = reset_value
      data_index = 1

      # Extract first code as a character
      bits = 0
      max_power = 2**2
      power = 1

      while power != max_power
        resb = data_val & data_position
        data_position >>= 1
        if data_position.zero?
          data_position = reset_value
          data_val = get_next_value.call(data_index)
          data_index += 1
        end

        bits |= (resb.positive? ? 1 : 0) * power
        power <<= 1
      end

      c = nil

      case bits
      when 0
        bits = 0
        max_power = 2**8
        power = 1

        while power != max_power
          resb = data_val & data_position
          data_position >>= 1
          if data_position.zero?
            data_position = reset_value
            data_val = get_next_value.call(data_index)
            data_index += 1
          end

          bits |= (resb.positive? ? 1 : 0) * power
          power <<= 1
        end

        # Convert to proper UTF-8 character
        c = begin
          bits.chr(Encoding::UTF_8)
        rescue
          "?"
        end
      when 1
        bits = 0
        max_power = 2**16
        power = 1

        while power != max_power
          resb = data_val & data_position
          data_position >>= 1
          if data_position.zero?
            data_position = reset_value
            data_val = get_next_value.call(data_index)
            data_index += 1
          end

          bits |= (resb.positive? ? 1 : 0) * power
          power <<= 1
        end

        # Convert to proper UTF-8 character
        c = begin
          bits.chr(Encoding::UTF_8)
        rescue
          "?"
        end
      when 2
        return ""
      end

      w = c
      result.push(c)
      dictionary[3] = c

      loop do
        return result.join.force_encoding(Encoding::UTF_8) if data_index > length

        # Read in bits for next code
        bits = 0
        max_power = 2**num_bits
        power = 1

        while power != max_power
          resb = data_val & data_position
          data_position >>= 1
          if data_position.zero?
            data_position = reset_value
            data_val = get_next_value.call(data_index)
            data_index += 1
          end

          bits |= (resb.positive? ? 1 : 0) * power
          power <<= 1
        end

        c = bits

        case c
        when 0
          bits = 0
          max_power = 2**8
          power = 1

          while power != max_power
            resb = data_val & data_position
            data_position >>= 1
            if data_position.zero?
              data_position = reset_value
              data_val = get_next_value.call(data_index)
              data_index += 1
            end

            bits |= (resb.positive? ? 1 : 0) * power
            power <<= 1
          end

          # Store character in dictionary
          begin
            dictionary[dict_size] = bits.chr(Encoding::UTF_8)
          rescue
            dictionary[dict_size] = "?"
          end
          dict_size += 1
          c = dict_size - 1
          enlarge_in -= 1
        when 1
          bits = 0
          max_power = 2**16
          power = 1

          while power != max_power
            resb = data_val & data_position
            data_position >>= 1
            if data_position.zero?
              data_position = reset_value
              data_val = get_next_value.call(data_index)
              data_index += 1
            end

            bits |= (resb.positive? ? 1 : 0) * power
            power <<= 1
          end

          # Store Unicode character in dictionary
          begin
            dictionary[dict_size] = bits.chr(Encoding::UTF_8)
          rescue
            dictionary[dict_size] = "?"
          end
          dict_size += 1
          c = dict_size - 1
          enlarge_in -= 1
        when 2
          # Final processing of result
          return result.join.force_encoding(Encoding::UTF_8)
        end

        if enlarge_in.zero?
          enlarge_in = 2**num_bits
          num_bits += 1
        end

        if dictionary[c]
          entry = dictionary[c]
        elsif c == dict_size
          entry = w + w[0]
        else
          return nil
        end

        result.push(entry)

        # Add w+entry[0] to the dictionary
        dictionary[dict_size] = w + entry[0]
        dict_size += 1
        enlarge_in -= 1

        if enlarge_in.zero?
          enlarge_in = 2**num_bits
          num_bits += 1
        end

        w = entry
      end
    rescue
      # Handle decompression errors gracefully
      nil
    end
  end
end
