# frozen_string_literal: true

module WahWah
  module ID3
    class Frame
      include Helper

      # Textual frames are marked with an encoding byte.
      #
      # $00   ISO-8859-1 [ISO-8859-1]. Terminated with $00.
      # $01   UTF-16 [UTF-16] encoded Unicode [UNICODE] with BOM.
      # $02   UTF-16BE [UTF-16] encoded Unicode [UNICODE] without BOM.
      # $03   UTF-8 [UTF-8] encoded Unicode [UNICODE].
      ENCODING_MAPPING = %w(ISO-8859-1 UTF-16 UTF-16BE UTF-8)

      ENCODING_TERMINATOR_SIZE = {
        'ISO-8859-1' => 1,
        'UTF-16' => 2,
        'UTF-16BE' => 2,
        'UTF-8' => 1
      }

      # ID3v2.3 frame flags field is defined as follows.
      #
      # %abc00000 %ijk00000
      #
      # a - Tag alter preservation
      # b - File alter preservation
      # c - Read only
      # i - Compression
      # j - Encryption
      # k - Grouping identity
      V3_HEADER_FLAGS_INDICATIONS = Array.new(16).tap do |array|
        array[0] = :tag_alter_preservation
        array[1] = :file_alter_preservation
        array[2] = :read_only
        array[8] = :compression
        array[9] = :encryption
        array[10] = :grouping_identity
      end

      # ID3v2.4 frame flags field is defined as follows.
      #
      # %0abc0000 %0h00kmnp
      #
      # a - Tag alter preservation
      # b - File alter preservation
      # c - Read only
      # h - Grouping identity
      # k - Compression
      # m - Encryption
      # n - Unsynchronisation
      # p - Data length indicator
      V4_HEADER_FLAGS_INDICATIONS = Array.new(16).tap do |array|
        array[1] = :tag_alter_preservation
        array[2] = :file_alter_preservation
        array[3] = :read_only
        array[9] = :grouping_identity
        array[12] = :compression
        array[13] = :encryption
        array[14] = :unsynchronisation
        array[15] = :data_length_indicator
      end

      attr_reader :id, :version, :name, :value

      def initialize(file_io, frame_header)
        @file_io = file_io
        @id = frame_header[:id]
        @name = frame_header[:name]
        @version = frame_header[:version]

        # Notice, ID3v2.4 frame header size on the most significant is set to zero in every byte
        @size = id3_size_caculate(frame_header[:size_bytes], has_zero_bit: @version == 4)
        @flags = parse_flags(frame_header[:flags_bytes])

        # In ID3v2.3 when frame is compressed using zlib
        # with 4 bytes for 'decompressed size' appended to the frame header.
        #
        # In ID3v2.4 A 'Data Length Indicator' byte MUST be included in the frame
        # when frame is compressed, and 'Data Length Indicator'represented as a 32 bit
        # synchsafe integer
        #
        # So skip those 4 byte.
        if compressed? || data_length_indicator?
          @file_io.seek(4, IO::SEEK_CUR)
          @size = @size - 4
        end

        parse if @size > 0
      end

      def invalid?
        @size <= 0
      end

      def compressed?
        @flags.include? :compression
      end

      def data_length_indicator?
        @flags.include? :data_length_indicator
      end

      def parse
        raise WahWahNotImplementedError, 'The parse method is not implemented'
      end

      private
        def parse_flags(flags_bytes)
          return [] if flags_bytes.nil?

          frame_flags_indications = @version == 4 ?
            V4_HEADER_FLAGS_INDICATIONS :
            V3_HEADER_FLAGS_INDICATIONS

          flags_bytes.split('').map.with_index do |flag_bit, index|
            frame_flags_indications[index] if flag_bit == '1'
          end.compact
        end
    end
  end
end
