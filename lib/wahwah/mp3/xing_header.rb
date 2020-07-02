# frozen_string_literal: true

module WahWah
  module Mp3
    # Xing header structure:
    #
    # Position                Length    Meaning
    # 0                       4         VBR header ID in 4 ASCII chars, either 'Xing' or 'Info',
    #                                   not NULL-terminated
    #
    # 4                       4         Flags which indicate what fields are present,
    #                                   flags are combined with a logical OR. Field is mandatory.
    #
    #                                   0x0001 - Frames field is present
    #                                   0x0002 - Bytes field is present
    #                                   0x0004 - TOC field is present
    #                                   0x0008 - Quality indicator field is present
    #
    # 8                       4         Number of Frames as Big-Endian 32-bit unsigned (optional)
    #
    # 8 or 12                 4         Number of Bytes in file as Big-Endian 32-bit unsigned (optional)
    #
    # 8,12 or 16              100       100 TOC entries for seeking as integral BYTE (optional)
    #
    # 8,12,16,108,112 or 116  4         Quality indicator as Big-Endian 32-bit unsigned
    #                                   from 0 - best quality to 100 - worst quality (optional)
    class XingHeader
      attr_reader :frames_count, :bytes_count

      def initialize(file_io, offset = 0)
        file_io.seek(offset)

        @id, @flags = file_io.read(8)&.unpack('A4N')
        return unless valid?

        @frames_count = @flags & 1 == 1 ? file_io.read(4).unpack('N').first : 0
        @bytes_count = @flags & 2 == 2 ? file_io.read(4).unpack('N').first : 0
      end

      def valid?
        %w(Xing Info).include? @id
      end
    end
  end
end
