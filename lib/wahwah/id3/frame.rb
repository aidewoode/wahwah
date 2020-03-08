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

      attr_reader :name, :value

      def initialize(file_io, major_version)
        @file_io = file_io
        @major_version = major_version

        header_size = (@major_version == 2) ? 6 : 10
        header_format = (@major_version == 2) ? "A3#{'B8' * 3}" : "A4#{'B8' * 4}"

        parse_frame(header_size, header_format)
      end

      def invalid?
        !defined? @name
      end

      private

        # ID3v2.2 frame header structure:
        #
        # Frame ID      $xx xx xx(tree characters)
        # Size          3 * %xxxxxxxx
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
        def parse_frame(header_size, header_format)
          frame_header = @file_io.read(header_size).unpack(header_format)
          frame_id = frame_header.first.to_sym

          # Notice, ID3v2.4 frame header size on the most significant is set to zero in every byte
          frame_size = id3_size_caculate(frame_header[1..-1], has_zero_bit: @major_version == 4)

          return unless frame_size > 0

          # Skip unused frame
          (@file_io.seek(frame_size, IO::SEEK_CUR); return) unless ID_MAPPING.keys.include? frame_id

          parse_frame_body(frame_size, ID_MAPPING[frame_id])
        end

        def parse_frame_body(frame_size, frame_name)
          @name = frame_name
          @value = case @name
                   when :comment
                     parse_comment_frame(frame_size)
                   when :genre
                     parse_genre_frame(frame_size)
                   else
                     parse_text_frame(frame_size)
          end
        end

        def parse_text_frame(frame_size)
          # Text frame boby structure:
          #
          # Text encoding  $xx
          # Information    <text string according to encoding>
          frame_body_encoding = ENCODING_MAPPING[@file_io.getbyte]
          encode_to_utf8(frame_body_encoding, @file_io.read(frame_size - 1))
        end

        def parse_genre_frame(frame_size)
          value = parse_text_frame(frame_size)

          # If value is numeric value, can use as index for ID3v1 genre list
          value.match?(/^(\d)+$/) ? ID3::V1::GENRES[value.to_i] : value
        end

        def parse_comment_frame(frame_size)
          # Comment frame body structure:
          # Frame size                $xx xx xx
          # Text encoding             $xx
          # Language                  $xx xx xx
          # Short content description <textstring> $00 (00)
          # The actual text           <textstring>
          frame_body_encoding = ENCODING_MAPPING[@file_io.getbyte]

          # Skip language content
          frame_body = @file_io.read(frame_size - 1)[3..-1]
          # Remove optional null bytes
          frame_body = frame_body.gsub(Regexp.new("^\xFF\xFE\x00\x00".b), '')

          encode_to_utf8(frame_body_encoding, frame_body)
        end
    end
  end
end
