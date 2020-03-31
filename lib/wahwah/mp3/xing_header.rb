# frozen_string_literal: true

module WahWah
  module Mp3
    # xing header structure:
    #
    # Position                Length    Meaning
    # 0                       4	        VBR header ID in 4 ASCII chars, either 'Xing' or 'Info',
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
    # 8	                      4	        Number of Frames as Big-Endian DWORD (optional)
    #
    # 8 or 12	                4	        Number of Bytes in file as Big-Endian DWORD (optional)
    #
    # 8,12 or 16	            100	      100 TOC entries for seeking as integral BYTE (optional)
    #
    # 8,12,16,108,112 or 116	4	        Quality indicator as Big-Endian DWORD
    #                                   from 0 - best quality to 100 - worst quality (optional)
    class XingHeader
      HEADER_READ_SIZE = 12

      attr_reader :frames

      def initialize(file_io, offset = 0)
        parse(file_io, offset)
      end

      def valid?
        %w(Xing Info).include?(@id) && (@flags & 1 == 1)
      end

      private
        def parse(file_io, offset)
          file_io.seek(offset)
          @id, flags_bits, frames_bits = file_io.read(HEADER_READ_SIZE).unpack('A4B32B32')

          @flags = flags_bits.to_i(2)
          @frames = frames_bits.to_i(2)
        end
    end
  end
end
