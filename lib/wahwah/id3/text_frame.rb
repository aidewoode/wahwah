# frozen_string_literal: true

module WahWah
  module ID3
    class TextFrame < Frame
      # Text frame boby structure:
      #
      # Text encoding  $xx
      # Information    <text string according to encoding>
      def parse
        encoding_id, text = @file_io.read(@size).unpack('Ca*')
        @value = encode_to_utf8(ENCODING_MAPPING[encoding_id], text)
      end
    end
  end
end
