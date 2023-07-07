# frozen_string_literal: true

module WahWah
  module ID3
    class Frame
      prepend LazyRead

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
        ULT: :lyrics,

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
        USLT: :lyrics,

        # ID3v2.4 use TDRC replace TYER
        TDRC: :year
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

      attr_reader :name

      def initialize(version)
        @version = version

        parse_frame_header

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
          @size -= 4
        end
      end

      def valid?
        @size > 0 && !@name.nil?
      end

      def compressed?
        @flags.include? :compression
      end

      def data_length_indicator?
        @flags.include? :data_length_indicator
      end

      def value
        return unless @size > 0

        content = compressed? ? Zlib.inflate(data) : data
        frame_body = frame_body_class.new(content, @version)
        frame_body.value
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
      def parse_frame_header
        header_size = @version == 2 ? 6 : 10
        header_formate = @version == 2 ? "A3B24" : "A4B32B16"
        id, size_bits, flags_bits = @file_io.read(header_size).unpack(header_formate)

        @name = ID_MAPPING[id.to_sym]
        @size = Helper.id3_size_caculate(size_bits, has_zero_bit: @version == 4)
        @flags = parse_flags(flags_bits)
      end

      def parse_flags(flags_bits)
        return [] if flags_bits.nil?

        frame_flags_indications = @version == 4 ?
          V4_HEADER_FLAGS_INDICATIONS :
          V3_HEADER_FLAGS_INDICATIONS

        flags_bits.chars.map.with_index do |flag_bit, index|
          frame_flags_indications[index] if flag_bit == "1"
        end.compact
      end

      def frame_body_class
        case @name
        when :comment
          CommentFrameBody
        when :genre
          GenreFrameBody
        when :image
          ImageFrameBody
        when :lyrics
          LyricsFrameBody
        else
          TextFrameBody
        end
      end
    end
  end
end
