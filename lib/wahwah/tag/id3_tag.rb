# frozen_string_literal: true

module WahWah
  class Id3Tag < Tag
    ID3V1_TAG_SIZE = 128
    ID3V1_TAG_ID = 'TAG'
    ID3V1_DEFAULT_ENCODING = 'iso-8859-1'

    def parse(file)
      @file = file

      if is_id3v1?
        parse_id3v1
      else
        parse_id3v2
      end
    end

    private

      def is_id3v1?
        @file.seek(-ID3V1_TAG_SIZE, IO::SEEK_END)
        @file.read(3) == ID3V1_TAG_ID
      end

      def parse_id3v1
        @file.seek(-(ID3V1_TAG_SIZE - ID3V1_TAG_ID.size), IO::SEEK_END)

        @title = encode_to_utf8(ID3V1_DEFAULT_ENCODING, @file.read(30).strip)
        @artist = encode_to_utf8(ID3V1_DEFAULT_ENCODING, @file.read(30).strip)
        @album = encode_to_utf8(ID3V1_DEFAULT_ENCODING, @file.read(30).strip)
        @year = encode_to_utf8(ID3V1_DEFAULT_ENCODING, @file.read(4).strip)
      end

      def parse_id3v2
      end
  end
end
