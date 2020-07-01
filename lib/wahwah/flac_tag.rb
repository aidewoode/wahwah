# frozen_string_literal: true

module WahWah
  class FlacTag < Tag
    include Ogg::VorbisComment
    include Flac::StreaminfoBlock

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

        loop do
          block = Flac::Block.new(@file_io)
          parse_block(block)

          break if block.is_last? || @file_io.eof?
        end
      end

      def parse_block(block)
        return unless block.valid?

        case block.type
        when 'STREAMINFO'
          parse_streaminfo_block(block.data)
        when 'VORBIS_COMMENT'
          parse_vorbis_comment(block.data)
        when 'PICTURE'
          parse_picture_block(block.data)
        else
          @file_io.seek(block.size, IO::SEEK_CUR)
        end
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
      def parse_picture_block(block_data)
        block_content = StringIO.new(block_data)

        type_index, mime_type_length = block_content.read(8).unpack('NN')
        mime_type = Helper.encode_to_utf8(block_content.read(mime_type_length))
        description_length = block_content.read(4).unpack('N').first
        data_length = block_content.read(description_length + 20).unpack("#{'x' * (description_length + 16)}N").first
        data = block_content.read(data_length)

        @images.push({ data: data, mime_type: mime_type, type: ID3::ImageFrameBody::TYPES[type_index] })
      end
  end
end
