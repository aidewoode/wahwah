# frozen_string_literal: true

module WahWah
  module Mp3
    # VBRI header structure:
    #
    # Position    Length    Meaning
    # 0           4         VBR header ID in 4 ASCII chars, always 'VBRI', not NULL-terminated
    #
    # 4           2         Version ID as Big-Endian 16-bit unsigned
    #
    # 6           2         Delay as Big-Endian float
    #
    # 8           2         Quality indicator
    #
    # 10          4         Number of Bytes as Big-Endian 32-bit unsigned
    #
    # 14          4         Number of Frames as Big-Endian 32-bit unsigned
    #
    # 18          2         Number of entries within TOC table as Big-Endian 16-bit unsigned
    #
    # 20          2         Scale factor of TOC table entries as Big-Endian 32-bit unsigned
    #
    # 22          2         Size per table entry in bytes (max 4) as Big-Endian 16-bit unsigned
    #
    # 24          2         Frames per table entry as Big-Endian 16-bit unsigned
    #
    # 26                    TOC entries for seeking as Big-Endian integral.
    #                       From size per table entry and number of entries,
    #                       you can calculate the length of this field.
    class VbriHeader
      HEADER_SIZE = 32
      HEADER_FORMAT = 'A4x6NN'

      attr_reader :frames_count, :bytes_count

      def initialize(file_io, offset = 0)
        file_io.seek(offset)
        @id, @bytes_count, @frames_count = file_io.read(HEADER_SIZE)&.unpack(HEADER_FORMAT)
      end

      def valid?
        @id == 'VBRI'
      end
    end
  end
end
