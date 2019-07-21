# frozen_string_literal: true

module WahWah
  module Helper
    def encode_to_utf8(source_encode, string)
      string.encode('utf-8', source_encode)
    end

    def read_bytes_from(file, position, length)
      file.seek(position)
      file.read(length).strip
    end
  end
end
