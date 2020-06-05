# frozen_string_literal: true

module WahWah
  module Helper
    def self.encode_to_utf8(string, source_encoding: '')
      return string.force_encoding('utf-8').strip if source_encoding.empty?
      string.encode('utf-8', source_encoding).strip
    end

    # ID3 size is encoded with four bytes where may the most significant
    # bit (bit 7) is set to zero in every byte,
    # making a total of 28 bits. The zeroed bits are ignored
    def self.id3_size_caculate(bits_string, has_zero_bit: true)
      if has_zero_bit
        bits_string.scan(/.{8}/).map { |byte_string| byte_string[1..-1] }.join.to_i(2)
      else
        bits_string.to_i(2)
      end
    end

    def self.split_with_terminator(string, terminator_size)
      string.split(Regexp.new(('\x00' * terminator_size).b), 2)
    end

    def self.file_format(file_path)
      File.extname(file_path).downcase.delete('.')
    end
  end
end
