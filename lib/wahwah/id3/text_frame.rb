# frozen_string_literal: true

module WahWah
  module ID3
    class TextFrame < Frame
      # Text frame boby structure:
      #
      # Text encoding  $xx
      # Information    <text string according to encoding>
      def parse
        frame_body_encoding = ENCODING_MAPPING[@file_io.getbyte]
        @value = encode_to_utf8(frame_body_encoding, @file_io.read(@size - 1))
      end
    end
  end
end
