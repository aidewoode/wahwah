# frozen_string_literal: true

module WahWah
  module ID3
    class CommentFrame < Frame
      # Comment frame body structure:
      # Frame size                $xx xx xx
      # Text encoding             $xx
      # Language                  $xx xx xx
      # Short content description <textstring> $00 (00)
      # The actual text           <textstring>
      def parse
        frame_body_encoding = ENCODING_MAPPING[@file_io.getbyte]

        # Skip language content
        frame_body = @file_io.read(@size - 1)[3..-1]
        # Remove optional null bytes
        frame_body = frame_body.gsub(Regexp.new("^\xFF\xFE\x00\x00".b), '')

        @value = encode_to_utf8(frame_body_encoding, frame_body)
      end
    end
  end
end
