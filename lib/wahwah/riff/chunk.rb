# frozen_string_literal: true

module WahWah
  module Riff
    # RIFF files consist entirely of "chunks".

    # All chunks have the following format:

    # 4 bytes: an ASCII identifier for this chunk (examples are "fmt " and "data"; note the space in "fmt ").
    # 4 bytes: an unsigned, little-endian 32-bit integer with the length of this chunk (except this field itself and the chunk identifier).
    # variable-sized field: the chunk data itself, of the size given in the previous field.
    # a pad byte, if the chunk's length is not even.

    # chunk identifiers, "RIFF" and "LIST", introduce a chunk that can contain subchunks. The RIFF and LIST chunk data (appearing after the identifier and length) have the following format:

    # 4 bytes: an ASCII identifier for this particular RIFF or LIST chunk (for RIFF in the typical case, these 4 bytes describe the content of the entire file, such as "AVI " or "WAVE").
    # rest of data: subchunks.
    class Chunk
      HEADER_SIZE = 8
      HEADER_FORMAT = 'A4V'
      HEADER_TYPE_SIZE = 4

      attr_reader :id, :type

      def initialize(file_io)
        @id, @size = file_io.read(HEADER_SIZE).unpack(HEADER_FORMAT)
        @type = file_io.read(HEADER_TYPE_SIZE).unpack('A4').first if have_type?
        @file_io = file_io
        @position = file_io.pos
      end

      def size
        @size = @size + 1 if @size.odd?
        have_type? ? @size - HEADER_TYPE_SIZE : @size
      end

      def data
        @file_io.seek(@position)
        @file_io.read(size)
      end

      private
        def have_type?
          %w(RIFF LIST).include? @id
        end
    end
  end
end
