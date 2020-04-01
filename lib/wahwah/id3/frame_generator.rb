# frozen_string_literal: true

module WahWah
  module ID3
    class FrameGenerator
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
        PIC: :image,

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
        APIC: :image,

        # ID3v2.4 use TDRC replace TYER
        TDRC: :year
      }

      class << self
        def generate(file_io, major_version)
          frame_header = major_version == 2 ?
            parse_v2_frame_header(file_io) :
            parse_v3_4_frame_header(file_io)

          frame_header[:name] = ID_MAPPING[frame_header[:id]]
          frame_header[:version] = major_version

          frame_class(frame_header[:name]).new(file_io, frame_header)
        end

        private
          # Parse ID3v2.2 frame
          #
          # ID3v2.2 frame header structure:
          #
          # Frame ID      $xx xx xx(tree characters)
          # Size          3 * %xxxxxxxx
          def parse_v2_frame_header(file_io)
            id, *size_bytes = file_io.read(6).unpack("A3#{'B8' * 3}")

            {}.tap do |hash|
              hash[:id] = id.to_sym
              hash[:size_bytes] = size_bytes

              # ID3 v2.2 don't have frame flags on header
              hash[:flags_bytes] = nil
            end
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
          def parse_v3_4_frame_header(file_io)
            id, *size_bytes, flags_bytes = file_io.read(10).unpack("A4#{'B8' * 4}B16")

            {}.tap do |hash|
              hash[:id] = id.to_sym
              hash[:size_bytes] = size_bytes
              hash[:flags_bytes] = flags_bytes
            end
          end

          def frame_class(frame_name)
            case frame_name
            when nil
              InvalidFrame
            when :comment
              CommentFrame
            when :genre
              GenreFrame
            when :image
              ImageFrame
            else
              TextFrame
            end
          end
      end
    end
  end
end
