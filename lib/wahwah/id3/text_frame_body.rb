# frozen_string_literal: true

module WahWah
  module ID3
    class TextFrameBody < FrameBody
      # Text frame boby structure:
      #
      # Text encoding  $xx
      # Information    <text string according to encoding>
      def parse
        encoding_id, text = @content.unpack('Ca*')
        @value = Helper.encode_to_utf8(text, source_encoding: ENCODING_MAPPING[encoding_id])
      end
    end
  end
end
