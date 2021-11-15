# frozen_string_literal: true

module WahWah
  module ID3
    class CommentFrameBody < FrameBody
      # Comment frame body structure:
      #
      # Text encoding             $xx
      # Language                  $xx xx xx
      # Short content description <textstring> $00 (00)
      # The actual text           <textstring>
      def parse
        encoding_id, _language, reset_content = @content.unpack("CA3a*")
        encoding = ENCODING_MAPPING[encoding_id]
        _description, comment_text = Helper.split_with_terminator(reset_content, ENCODING_TERMINATOR_SIZE[encoding])

        @value = Helper.encode_to_utf8(comment_text, source_encoding: encoding)
      end
    end
  end
end
