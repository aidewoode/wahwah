# frozen_string_literal: true

module WahWah
  module Helper
    def encode_to_utf8(source_encode, string)
      # Remove optional zero byte on binary string
      string = string.gsub(Regexp.new("^\x00*".b), '')

      return string if source_encode.downcase == 'utf-8'
      string.encode('utf-8', source_encode).strip
    end

    # ID3 size is encoded with four bytes where may the most significant
    # bit (bit 7) is set to zero in every byte,
    # making a total of 28 bits. The zeroed bits are ignored
    def id3_size_caculate(byte_strings, has_zero_bit: true)
      if has_zero_bit
        byte_strings.map { |byte_string| byte_string[1..-1] }.join.to_i(2)
      else
        byte_strings.join.to_i(2)
      end
    end
  end
end
