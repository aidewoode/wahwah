# frozen_string_literal: true

module WahWah
  class Mp3Tag < Tag
    include ID3::Delegate

    def id3v1?
      @id3_version == 1
    end

    def id3v2?
      @id3_version == 2
    end

    def invalid_id3?
      @id3_version == 0
    end

    def id3_version
      if id3v1?
        'v1'
      elsif id3v2?
        "v#{@id3_version}.#{@id3_tag.major_version}"
      end
    end

    def mpeg_version
      mpeg_frame_header.version
    end

    def mpeg_layer
      mpeg_frame_header.layer
    end

    def mpeg_kind
      mpeg_frame_header.kind
    end

    def channel_mode
      mpeg_frame_header.channel_mode
    end

    def sample_rate
      mpeg_frame_header.sample_rate
    end

    def is_vbr?
      xing_header.valid? || vbri_header.valid?
    end

    private
      def parse
        parse_id3_version
        parse_tag
        parse_duration
      end

      def parse_id3_version
        # Invalid id3 version
        @id3_version = 0

        @file_io.seek(-ID3::V1::TAG_SIZE, IO::SEEK_END)
        @id3_version = 1 if @file_io.read(3) == ID3::V1::TAG_ID

        @file_io.rewind
        @id3_version = 2 if @file_io.read(3) == ID3::V2::TAG_ID
      end

      def parse_tag
        @id3_tag = if id3v2?
          ID3::V2.new(@file_io)
        elsif id3v1?
          ID3::V1.new(@file_io)
        end
      end

      def parse_duration
        if is_vbr?
          @duration = (frames_count * (mpeg_frame_header.samples_per_frame / sample_rate.to_f)).round
          @bitrate = bytes_count * 8 / @duration / 1000
        else
          @bitrate = mpeg_frame_header.frame_bitrate
          @duration = (file_size - (@id3_tag&.size || 0)) * 8 / (@bitrate * 1000) unless @bitrate.zero?
        end
      end

      def mpeg_frame_header
        # Because id3v2 tag on the file header so skip id3v2 tag
        @mpeg_frame_header ||= Mp3::MpegFrameHeader.new(@file_io, id3v2? ? @id3_tag&.size : 0)
      end

      def xing_header
        @xing_header ||= Mp3::XingHeader.new(@file_io, xing_header_offset)
      end

      def vbri_header
        @vbri_header ||= Mp3::VbriHeader.new(@file_io, vbri_header_offset)
      end

      def xing_header_offset
        mpeg_frame_header_position = mpeg_frame_header.position
        mpeg_frame_header_size = Mp3::MpegFrameHeader::HEADER_SIZE
        mpeg_frame_side_info_size = mpeg_version == 'MPEG1' ?
          (channel_mode == 'Single Channel' ? 17 : 32) :
          (channel_mode == 'Single Channel' ? 9 : 17)

        mpeg_frame_header_position + mpeg_frame_header_size + mpeg_frame_side_info_size
      end

      def vbri_header_offset
        mpeg_frame_header_position = mpeg_frame_header.position
        mpeg_frame_header_size = Mp3::MpegFrameHeader::HEADER_SIZE

        mpeg_frame_header_position + mpeg_frame_header_size
      end

      def frames_count
        return xing_header.frames_count if xing_header.valid?
        vbri_header.frames_count if vbri_header.valid?
      end

      def bytes_count
        return xing_header.bytes_count if xing_header.valid?
        vbri_header.bytes_count if vbri_header.valid?
      end
  end
end
