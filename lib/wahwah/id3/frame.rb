# frozen_string_literal: true

module WahWah
  module ID3
    class Frame
      include Helper

      ID_MAPPING = {
        # ID3v2.2 frame id
        COM: :comment,
        TRK: :track,
        TYE: :year,
        TAL: :album,
        TP1: :artist,
        TT2: :title,
        TCO: :genre,
        TPA: :disc,
        TP2: :albumartist,
        TCM: :composer,

        # ID3v2.3 and ID3v2.4 frame id
        COMM: :comment,
        TRCK: :track,
        TYER: :year,
        TALB: :album,
        TPE1: :artist,
        TIT2: :title,
        TCON: :genre,
        TPOS: :disc,
        TPE2: :albumartist,
        TCOM: :composer,

        # ID3v2.4 use TDRC replace TYER
        TDRC: :year
      }

      # Textual frames are marked with an encoding byte.
      #
      # $00   ISO-8859-1 [ISO-8859-1]. Terminated with $00.
      # $01   UTF-16 [UTF-16] encoded Unicode [UNICODE] with BOM.
      # $02   UTF-16BE [UTF-16] encoded Unicode [UNICODE] without BOM.
      # $03   UTF-8 [UTF-8] encoded Unicode [UNICODE].
      ENCODING_MAPPING = ['ISO-8859-1', 'UTF-16', 'UTF-16BE', 'UTF-8']

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

      attr_reader :name, :value

      def initialize(file_io, major_version)
        @file_io = file_io
        @major_version = major_version

        parse_frame
      end

      def invalid?
        !defined? @name
      end

      def compressed?
        @frame_flags.include? :compression
      end

      def data_length_indicator?
        @frame_flags.include? :data_length_indicator
      end

      private

        def parse_frame
          if @major_version == 2
            parse_v2_frame
          else
            parse_v3_4_frame
          end

          return unless @frame_size > 0

          # Skip unused frame
          (@file_io.seek(@frame_size, IO::SEEK_CUR); return) unless ID_MAPPING.keys.include? @frame_id

          parse_frame_body
        end

        # Parse ID3v2.2 frame
        #
        # ID3v2.2 frame header structure:
        #
        # Frame ID      $xx xx xx(tree characters)
        # Size          3 * %xxxxxxxx
        def parse_v2_frame
          frame_header = @file_io.read(6).unpack("A3#{'B8' * 3}")
          @frame_id = frame_header.first.to_sym
          @frame_size = id3_size_caculate(frame_header[1..-1])

          # ID3 v2.2 don't have frame flags on header
          @frame_flags = []
        end

        # Parse ID3v2.3 and v2.4 frame
        #
        # ID3v2.3 frame header structure:
        #
        # Frame ID      $xx xx xx xx (four characters)
        # Size          4 * %xxxxxxxx
        # Flags         $xx xx
        #
        # ID3v2.4 frame header structure:
        #
        # Frame ID      $xx xx xx xx (four characters)
        # Size          4 * %0xxxxxxx
        # Flags         $xx xx
        def parse_v3_4_frame
          frame_flags_indications = @major_version == 4 ?
            V4_HEADER_FLAGS_INDICATIONS :
            V3_HEADER_FLAGS_INDICATIONS

          frame_header = @file_io.read(10).unpack("A4#{'B8' * 4}B16")
          @frame_id = frame_header.first.to_sym

          # Notice, ID3v2.4 frame header size on the most significant is set to zero in every byte
          @frame_size = id3_size_caculate(frame_header[1, 4], has_zero_bit: @major_version == 4)

          # ID3 frame flags first byte is for status, second byte is for formate
          @frame_flags = frame_header.last.split('').map.with_index do |flag_bit, index|
            frame_flags_indications[index] if flag_bit == '1'
          end.compact

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
            @frame_size = @frame_size - 4
          end
        end

        def parse_frame_body
          @name = ID_MAPPING[@frame_id]
          @value = case @name
                   when :comment
                     parse_comment_frame
                   when :genre
                     parse_genre_frame
                   else
                     parse_text_frame
          end
        end

        def parse_text_frame
          # Text frame boby structure:
          #
          # Text encoding  $xx
          # Information    <text string according to encoding>
          frame_body_encoding = ENCODING_MAPPING[@file_io.getbyte]
          encode_to_utf8(frame_body_encoding, @file_io.read(@frame_size - 1))
        end

        def parse_genre_frame
          value = parse_text_frame

          # If value is numeric value, or contain numeric value in parens
          # can use as index for ID3v1 genre list
          (value =~ /^\((\d+)\)$/ || value =~ /^(\d+)$/) ? ID3::V1::GENRES[$1.to_i] : value
        end

        def parse_comment_frame
          # Comment frame body structure:
          # Frame size                $xx xx xx
          # Text encoding             $xx
          # Language                  $xx xx xx
          # Short content description <textstring> $00 (00)
          # The actual text           <textstring>
          frame_body_encoding = ENCODING_MAPPING[@file_io.getbyte]

          # Skip language content
          frame_body = @file_io.read(@frame_size - 1)[3..-1]
          # Remove optional null bytes
          frame_body = frame_body.gsub(Regexp.new("^\xFF\xFE\x00\x00".b), '')

          encode_to_utf8(frame_body_encoding, frame_body)
        end
    end
  end
end
