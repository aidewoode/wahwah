# frozen_string_literal: true

module WahWah
  module ID3
    class ImageFrameBody < FrameBody
      TYPES = %i(
        other
        file_icon
        other_file_icon
        cover_front
        cover_back
        leaflet
        media
        lead_artist
        artist
        conductor
        band
        composer
        lyricist
        recording_location
        during_recording
        during_performance
        movie_screen_capture
        bright_coloured_fish
        illustration
        band_logotype
        publisher_logotype
      )

      def mime_type
        mime_type = @mime_type.downcase.yield_self { |type| type == 'jpg' ? 'jpeg' : type }
        @version > 2 ? mime_type : "image/#{mime_type}"
      end

      # ID3v2.2 image frame structure:
      #
      # Text encoding  $xx
      # Image format   $xx xx xx
      # Picture type   $xx
      # Description    <text string according to encoding> $00 (00)
      # Picture data   <binary data>
      #
      # ID3v2.3 and ID3v2.4 image frame structure:
      #
      # Text encoding $xx
      # MIME type     <text string> $00
      # Picture type  $xx
      # Description   <text string according to encoding> $00 (00)
      # Picture data  <binary data>
      def parse
        frame_format = @version > 2 ? 'CZ*Ca*' : 'Ca3Ca*'
        encoding_id, @mime_type, picture_id, reset_content = @content.unpack(frame_format)
        encoding = ENCODING_MAPPING[encoding_id]
        _description, data = Helper.split_with_terminator(reset_content, ENCODING_TERMINATOR_SIZE[encoding])

        @value = { data: data, mime_type: mime_type, type: TYPES[picture_id] }
      end
    end
  end
end
