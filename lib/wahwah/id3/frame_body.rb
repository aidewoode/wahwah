# frozen_string_literal: true

module WahWah
  module ID3
    class FrameBody
      # Textual frames are marked with an encoding byte.
      #
      # $00   ISO-8859-1 [ISO-8859-1]. Terminated with $00.
      # $01   UTF-16 [UTF-16] encoded Unicode [UNICODE] with BOM.
      # $02   UTF-16BE [UTF-16] encoded Unicode [UNICODE] without BOM.
      # $03   UTF-8 [UTF-8] encoded Unicode [UNICODE].
      ENCODING_MAPPING = %w[ISO-8859-1 UTF-16 UTF-16BE UTF-8]

      ENCODING_TERMINATOR_SIZE = {
        "ISO-8859-1" => 1,
        "UTF-16" => 2,
        "UTF-16BE" => 2,
        "UTF-8" => 1
      }

      attr_reader :value

      def initialize(content, version)
        @content = content
        @version = version

        parse
      end

      def parse
        raise WahWahNotImplementedError, "The parse method is not implemented"
      end
    end
  end
end
