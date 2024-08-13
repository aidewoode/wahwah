# frozen_string_literal: true

module WahWah
  module Helper
    def self.encode_to_utf8(string, source_encoding: "")
      encoded_string = source_encoding.empty? ?
        string.force_encoding("utf-8") :
        string.encode("utf-8", source_encoding, invalid: :replace, undef: :replace, replace: "")

      encoded_string.valid_encoding? ? encoded_string.strip : ""
    end

    # ID3 size is encoded with four bytes where may the most significant
    # bit (bit 7) is set to zero in every byte,
    # making a total of 28 bits. The zeroed bits are ignored
    def self.id3_size_caculate(bits_string, has_zero_bit: true)
      if has_zero_bit
        bits_string.scan(/.{8}/).map { |byte_string| byte_string[1..] }.join.to_i(2)
      else
        bits_string.to_i(2)
      end
    end

    def self.split_with_terminator(string, terminator_size)
      terminator = ("\x00" * terminator_size).b

      (0...string.size).step(terminator_size).each do |index|
        if string[index...(index + terminator_size)] == terminator
          return [string[0...index], string[index + terminator_size..]]
        end
      end

      []
    end

    def self.file_format(io)
      if io.respond_to?(:path) && io.path && !io.path.empty?
        file_format = file_format_from_extension io.path
        return file_format unless file_format.nil? || file_format.empty?
      end

      file_format_from_signature io
    end

    def self.byte_string_to_guid(byte_string)
      guid = byte_string.unpack("NnnA*").pack("VvvA*").unpack1("H*")
      [guid[0..7], guid[8..11], guid[12..15], guid[16..19], guid[20..]].join("-").upcase
    end

    def self.file_format_from_extension(file_path)
      File.extname(file_path).downcase[1..]
    end

    def self.file_format_from_signature(io)
      io.rewind
      signature = io.read(16)
      # Rewind after reading the signature to not mess with the file position
      io.rewind

      # Source: https://en.wikipedia.org/wiki/List_of_file_signatures

      # M4A is checked for first, since MP4 files start with a chunk size -
      # and that chunk size may incidentally match another signature.
      # No other formats would reasonably have "ftyp" as the next for bytes.
      return "m4a" if ["ftypM4A ".b, "ftyp3gp4".b].include?(signature[4...12])
      # Handled separately simply because it requires two checks.
      return "wav" if signature.start_with?("RIFF".b) && signature[8...12] == "WAVE".b
      magic_numbers = {
        "fLaC".b => "flac",
        "\xFF\xFB".b => "mp3",
        "\xFF\xF3".b => "mp3",
        "\xFF\xF2".b => "mp3",
        "ID3".b => "mp3",
        "OggS".b => "ogg",
        "\x30\x26\xB2\x75\x8E\x66\xCF\x11\xA6\xD9\x00\xAA\x00\x62\xCE\x6C".b => "wma"
      }
      magic_numbers.each do |expected_signature, file_format|
        return file_format if signature.start_with? expected_signature
      end

      nil
    end

    private_class_method :file_format_from_extension, :file_format_from_signature
  end
end
