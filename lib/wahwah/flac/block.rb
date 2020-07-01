# frozen_string_literal: true

module WahWah
  module Flac
    class Block
      HEADER_SIZE = 4
      HEADER_FORMAT = 'B*'
      BLOCK_TYPE_INDEX = %w(STREAMINFO PADDING APPLICATION SEEKTABLE VORBIS_COMMENT CUESHEET PICTURE)

      attr_reader :size, :type

      def initialize(file_io)
        # Block header structure:
        #
        # Length(bit)  Meaning
        #
        # 1            Last-metadata-block flag:
        #              '1' if this block is the last metadata block before the audio blocks, '0' otherwise.
        #
        # 7            BLOCK_TYPE
        #              0 : STREAMINFO
        #              1 : PADDING
        #              2 : APPLICATION
        #              3 : SEEKTABLE
        #              4 : VORBIS_COMMENT
        #              5 : CUESHEET
        #              6 : PICTURE
        #              7-126 : reserved
        #              127 : invalid, to avoid confusion with a frame sync code
        #
        # 24           Length (in bytes) of metadata to follow
        #              (does not include the size of the METADATA_BLOCK_HEADER)
        header_bits = file_io.read(HEADER_SIZE).unpack(HEADER_FORMAT).first

        @last_flag = header_bits[0]
        @type = BLOCK_TYPE_INDEX[header_bits[1..7].to_i(2)]
        @size = header_bits[8..-1].to_i(2)

        @file_io = file_io
        @position = file_io.pos
      end

      def valid?
        @size > 0
      end

      def is_last?
        @last_flag.to_i == 1
      end

      def data
        @file_io.seek(@position)
        @file_io.read(size)
      end
    end
  end
end
