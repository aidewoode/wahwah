# frozen_string_literal: true

module WahWah
  module ID3
    # The ID3v2 tag header, which should be the first information in the file,
    # is 10 bytes as follows:

    # ID3v2/file identifier   "ID3"
    # ID3v2 version           $03 00
    # ID3v2 flags             %abc00000
    # ID3v2 size              4 * %0xxxxxxx
    class V2Header
      TAG_ID = "ID3"
      HEADER_SIZE = 10
      HEADER_FORMAT = "A3CxB8B*"

      attr_reader :major_version, :size

      def initialize(file_io)
        header_content = file_io.read(HEADER_SIZE) || ""
        @id, @major_version, @flags, size_bits = header_content.unpack(HEADER_FORMAT) if header_content.size >= HEADER_SIZE

        return unless valid?

        # Tag size is the size excluding the header size,
        # so add header size back to get total size.
        @size = Helper.id3_size_caculate(size_bits) + HEADER_SIZE

        if has_extended_header?
          # Extended header structure:
          #
          # Extended header size   $xx xx xx xx
          # Extended Flags         $xx xx
          # Size of padding        $xx xx xx xx

          # Skip extended_header
          extended_header_size = Helper.id3_size_caculate(file_io.read(4).unpack1("B32"))
          file_io.seek(extended_header_size - 4, IO::SEEK_CUR)
        end
      end

      def valid?
        @id == TAG_ID
      end

      # The second bit in flags byte indicates whether or not the header
      # is followed by an extended header.
      def has_extended_header?
        @flags[1] == "1"
      end
    end
  end
end
