# frozen_string_literal: true

module WahWah
  class FlacTag < Tag
    include Ogg::VorbisComment

    TAG_ID = 'fLaC'

    private
      # FLAC structure:
      #
      # The four byte string "fLaC"
      # The STREAMINFO metadata block
      # Zero or more other metadata blocks
      # One or more audio frames
      def parse
        # Flac file maybe contain ID3 header on the start, so skip it if exists
        id3_header = ID3::V2Header.new(@file_io)
        id3_header.valid? ? @file_io.seek(id3_header.size) : @file_io.rewind

        return if @file_io.read(4) != TAG_ID

        parse_blocks
      end

      def parse_blocks
        loop do
          block = Flac::Block.new(@file_io)

          case block.type
          when 'STREAMINFO'
            parse_stresminfo_block(block)
          when 'VORBIS_COMMENT'
            parse_vorbis_comment_block(block)
          when 'PICTURE'
            parse_picture_block(block)
          else
            @file_io.seek(block.size, IO::SEEK_CUR)
          end

          break if block.is_last?
        end
      end

      # STREAMINFO block data structure:
      #
      # Length(bit)  Meaning
      #
      # 16           The minimum block size (in samples) used in the stream.
      #
      # 16           The maximum block size (in samples) used in the stream.
      #              (Minimum blocksize == maximum blocksize) implies a fixed-blocksize stream.
      #
      # 24           The minimum frame size (in bytes) used in the stream.
      #              May be 0 to imply the value is not known.
      #
      # 24          The maximum frame size (in bytes) used in the stream.
      #              May be 0 to imply the value is not known.
      #
      # 20           Sample rate in Hz. Though 20 bits are available,
      #              the maximum sample rate is limited by the structure of frame headers to 655350Hz.
      #              Also, a value of 0 is invalid.
      #
      # 3            (number of channels)-1. FLAC supports from 1 to 8 channels
      #
      # 5            (bits per sample)-1. FLAC supports from 4 to 32 bits per sample.
      #              Currently the reference encoder and decoders only support up to 24 bits per sample.
      #
      # 36           Total samples in stream. 'Samples' means inter-channel sample,
      #              i.e. one second of 44.1Khz audio will have 44100 samples regardless of the number of channels.
      #              A value of zero here means the number of total samples is unknown.
      #
      # 128          MD5 signature of the unencoded audio data.
      def parse_stresminfo_block(block)
        info_bits = block.data.unpack('x10B64').first

        sample_rate = info_bits[0..19].to_i(2)
        bits_per_sample = info_bits[23..27].to_i(2) + 1
        total_samples = info_bits[28..-1].to_i(2)

        @duration = (total_samples.to_f / sample_rate).round if sample_rate > 0
        @bitrate =  sample_rate * bits_per_sample / 1000
      end

      def parse_vorbis_comment_block(block)
        parse_vorbis_comment(block.data)
      end

      # PICTURE block data structure:
      #
      # Length(bit)  Meaning
      #
      # 32           The picture type according to the ID3v2 APIC frame:
      #
      # 32           The length of the MIME type string in bytes.
      #
      # n*8          The MIME type string.
      #
      # 32           The length of the description string in bytes.
      #
      # n*8          The description of the picture, in UTF-8.
      #
      # 32           The width of the picture in pixels.
      #
      # 32           The height of the picture in pixels.
      #
      # 32           The color depth of the picture in bits-per-pixel.
      #
      # 32           For indexed-color pictures (e.g. GIF), the number of colors used, or 0 for non-indexed pictures.
      #
      # 32           The length of the picture data in bytes.
      #
      # n*8          The binary picture data.
      def parse_picture_block(block)
        block_content = StringIO.new(block.data)

        type_index, mime_type_length = block_content.read(8).unpack('NN')
        mime_type = Helper.encode_to_utf8(block_content.read(mime_type_length))
        description_length = block_content.read(4).unpack('N').first
        data_length = block_content.read(description_length + 20).unpack("#{'x' * (description_length + 16)}N").first
        data = block_content.read(data_length)

        @images.push({ data: data, mime_type: mime_type, type: ID3::ImageFrameBody::TYPES[type_index] })
      end
  end
end
