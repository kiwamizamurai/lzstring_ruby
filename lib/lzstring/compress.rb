module LZString
  # Internal method for compression
  # @param [String] uncompressed Input string to compress
  # @param [Integer] bits_per_char Number of bits per character in the output
  # @yield [Integer] Block that converts an integer to a character
  # @yieldparam [Integer] code Integer to convert to a character
  # @yieldreturn [String] Character representation of the integer
  # @return [String] Compressed string
  def self._compress(uncompressed, bits_per_char)
    return "" if uncompressed.nil? || uncompressed.empty?

    # Force input to UTF-8 encoding
    uncompressed = uncompressed.to_s.dup.force_encoding(Encoding::UTF_8)

    context_dictionary = {}
    context_dictionary_to_create = {}
    context_c = ""
    context_wc = ""
    context_w = ""
    context_enlarge_in = 2 # Compensate for the first entry which should not count
    context_dict_size = 3
    context_num_bits = 2
    context_data = []
    context_data_val = 0
    context_data_position = 0

    # Process each character (handling Unicode correctly)
    uncompressed.each_char do |c|
      context_c = c

      # Add to dictionary if not present
      unless context_dictionary.key?(context_c)
        context_dictionary[context_c] = context_dict_size
        context_dict_size += 1
        context_dictionary_to_create[context_c] = true
      end

      context_wc = context_w + context_c
      if context_dictionary.key?(context_wc)
        context_w = context_wc
      else
        if context_dictionary_to_create.key?(context_w)
          # Get code point value
          code_point = context_w[0].ord

          if code_point < 128
            # ASCII character - output numBits followed by 8 bits
            context_num_bits.times do |_i|
              context_data_val = (context_data_val << 1)
              if context_data_position == bits_per_char - 1
                context_data_position = 0
                context_data.push(yield(context_data_val))
                context_data_val = 0
              else
                context_data_position += 1
              end
            end

            value = code_point
            8.times do |_i|
              context_data_val = (context_data_val << 1) | (value & 1)
              if context_data_position == bits_per_char - 1
                context_data_position = 0
                context_data.push(yield(context_data_val))
                context_data_val = 0
              else
                context_data_position += 1
              end
              value >>= 1
            end
          else
            # Unicode character - output numBits with flag=1, followed by 16 bits
            value = 1
            context_num_bits.times do |_i|
              context_data_val = (context_data_val << 1) | value
              if context_data_position == bits_per_char - 1
                context_data_position = 0
                context_data.push(yield(context_data_val))
                context_data_val = 0
              else
                context_data_position += 1
              end
              value = 0
            end

            value = code_point
            16.times do |_i|
              context_data_val = (context_data_val << 1) | (value & 1)
              if context_data_position == bits_per_char - 1
                context_data_position = 0
                context_data.push(yield(context_data_val))
                context_data_val = 0
              else
                context_data_position += 1
              end
              value >>= 1
            end
          end

          context_enlarge_in -= 1
          if context_enlarge_in.zero?
            context_enlarge_in = 1 << context_num_bits # Math.pow(2, context_numBits)
            context_num_bits += 1
          end

          context_dictionary_to_create.delete(context_w)
        else
          value = context_dictionary[context_w]
          context_num_bits.times do |_i|
            context_data_val = (context_data_val << 1) | (value & 1)
            if context_data_position == bits_per_char - 1
              context_data_position = 0
              context_data.push(yield(context_data_val))
              context_data_val = 0
            else
              context_data_position += 1
            end
            value >>= 1
          end
        end

        context_enlarge_in -= 1
        if context_enlarge_in.zero?
          context_enlarge_in = 1 << context_num_bits # Math.pow(2, context_numBits)
          context_num_bits += 1
        end

        # Add wc to the dictionary
        context_dictionary[context_wc] = context_dict_size
        context_dict_size += 1
        context_w = context_c
      end
    end

    # Output the code for w
    if context_w != ""
      if context_dictionary_to_create.key?(context_w)
        # Get code point value
        code_point = context_w[0].ord

        if code_point < 128
          # ASCII character
          context_num_bits.times do |_i|
            context_data_val = (context_data_val << 1)
            if context_data_position == bits_per_char - 1
              context_data_position = 0
              context_data.push(yield(context_data_val))
              context_data_val = 0
            else
              context_data_position += 1
            end
          end

          value = code_point
          8.times do |_i|
            context_data_val = (context_data_val << 1) | (value & 1)
            if context_data_position == bits_per_char - 1
              context_data_position = 0
              context_data.push(yield(context_data_val))
              context_data_val = 0
            else
              context_data_position += 1
            end
            value >>= 1
          end
        else
          # Unicode character
          value = 1
          context_num_bits.times do |_i|
            context_data_val = (context_data_val << 1) | value
            if context_data_position == bits_per_char - 1
              context_data_position = 0
              context_data.push(yield(context_data_val))
              context_data_val = 0
            else
              context_data_position += 1
            end
            value = 0
          end

          value = code_point
          16.times do |_i|
            context_data_val = (context_data_val << 1) | (value & 1)
            if context_data_position == bits_per_char - 1
              context_data_position = 0
              context_data.push(yield(context_data_val))
              context_data_val = 0
            else
              context_data_position += 1
            end
            value >>= 1
          end
        end

        context_enlarge_in -= 1
        if context_enlarge_in.zero?
          context_enlarge_in = 1 << context_num_bits # Math.pow(2, context_numBits)
          context_num_bits += 1
        end

        context_dictionary_to_create.delete(context_w)
      else
        value = context_dictionary[context_w]
        context_num_bits.times do |_i|
          context_data_val = (context_data_val << 1) | (value & 1)
          if context_data_position == bits_per_char - 1
            context_data_position = 0
            context_data.push(yield(context_data_val))
            context_data_val = 0
          else
            context_data_position += 1
          end
          value >>= 1
        end
      end

      context_enlarge_in -= 1
      if context_enlarge_in.zero?
        context_enlarge_in = 1 << context_num_bits # Math.pow(2, context_numBits)
        context_num_bits += 1
      end
    end

    # Mark the end of the stream
    value = 2
    context_num_bits.times do |_i|
      context_data_val = (context_data_val << 1) | (value & 1)
      if context_data_position == bits_per_char - 1
        context_data_position = 0
        context_data.push(yield(context_data_val))
        context_data_val = 0
      else
        context_data_position += 1
      end
      value >>= 1
    end

    # Flush the last char
    loop do
      context_data_val = (context_data_val << 1)
      if context_data_position == bits_per_char - 1
        context_data.push(yield(context_data_val))
        break
      else
        context_data_position += 1
      end
    end

    context_data.join
  end
end
