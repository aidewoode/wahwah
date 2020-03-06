# frozen_string_literal: true

module WahWah
  module ID3
    class V2 < Tag
      TAG_ID = 'ID3'
      HEADER_FORMAT = "A3CC#{'B8' * 5}"

      attr_reader :major_version, :tag_flags, :tag_size

      def parse
        parse_header
      end

      # The second bit in flags byte indicates whether or not the header
      # is followed by an extended header.
      def has_extended_header?
        tag_flags[1] == '1'
      end

      private

        # The ID3v2 tag header, which should be the first information in the file,
        # is 10 bytes as follows:

        # ID3v2/file identifier   "ID3"
        # ID3v2 version           $03 00
        # ID3v2 flags             %abc00000
        # ID3v2 size              4 * %0xxxxxxx
        def parse_header
          @file_io.rewind
          header = @file_io.read(10).unpack(HEADER_FORMAT)

          # The first byte of ID3v2 version is it's major version,
          # while the second byte is its revision number, we don't need
          # revision number here, so ignore it.
          @major_version = header[1]
          @flags = header[3]

          # Size is encoded with four bytes where the most significant
          # bit (bit 7) is set to zero in every byte,
          # making a total of 28 bits. The zeroed bits are ignored
          @tag_size = header[4, 4].map { |byte_string| byte_string[1..-1] }.join.to_i(2)
        end
    end
  end
end
