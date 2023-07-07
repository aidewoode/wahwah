# frozen_string_literal: true

module WahWah
  class Mp3Tag < Tag
    extend TagDelegate
    extend Forwardable

    def_delegator :@mpeg_frame_header, :version, :mpeg_version
    def_delegator :@mpeg_frame_header, :layer, :mpeg_layer
    def_delegator :@mpeg_frame_header, :kind, :mpeg_kind
    def_delegators :@mpeg_frame_header, :channel_mode, :sample_rate

    tag_delegate :@id3_tag,
      :title,
      :artist,
      :album,
      :albumartist,
      :composer,
      :comments,
      :track,
      :track_total,
      :genre,
      :year,
      :disc,
      :disc_total,
      :images,
      :lyrics

    def id3v2?
      @id3_tag.instance_of? ID3::V2
    end

    def invalid_id3?
      @id3_tag.nil?
    end

    def id3_version
      @id3_tag&.version
    end

    def is_vbr?
      mpeg_frame_header.valid? && (xing_header.valid? || vbri_header.valid?)
    end

    private

    def parse
      @id3_tag = parse_id3_tag
      parse_duration if mpeg_frame_header.valid?
    end

    def parse_id3_tag
      id3_v1_tag = ID3::V1.new(@file_io.dup)
      id3_v2_tag = ID3::V2.new(@file_io.dup)

      return id3_v2_tag if id3_v2_tag.valid?
      id3_v1_tag if id3_v1_tag.valid?
    end

    def parse_duration
      if is_vbr?
        @duration = frames_count * (mpeg_frame_header.samples_per_frame / sample_rate.to_f)
        @bitrate = (bytes_count * 8 / @duration / 1000).round unless @duration.zero?
      else
        @bitrate = mpeg_frame_header.frame_bitrate
        @duration = (file_size - (@id3_tag&.size || 0)) * 8 / (@bitrate * 1000).to_f unless @bitrate.zero?
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
      mpeg_frame_side_info_size = if mpeg_version == "MPEG1"
        channel_mode == "Single Channel" ? 17 : 32
      else
        channel_mode == "Single Channel" ? 9 : 17
      end

      mpeg_frame_header_position + mpeg_frame_header_size + mpeg_frame_side_info_size
    end

    def vbri_header_offset
      mpeg_frame_header_position = mpeg_frame_header.position
      mpeg_frame_header_size = Mp3::MpegFrameHeader::HEADER_SIZE

      mpeg_frame_header_position + mpeg_frame_header_size + 32
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
