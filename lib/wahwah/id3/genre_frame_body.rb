# frozen_string_literal: true

module WahWah
  module ID3
    class GenreFrameBody < TextFrameBody
      def parse
        super

        # If value is numeric value, or contain numeric value in parens
        # can use as index for ID3v1 genre list
        @value = ID3::V1::GENRES[$1.to_i] if @value =~ /^\((\d+)\)$/ || @value =~ /^(\d+)$/
      end
    end
  end
end
