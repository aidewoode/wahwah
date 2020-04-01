# frozen_string_literal: true

module WahWah
  module ID3
    class InvalidFrame
      include Helper

      def initialize(file_io, frame_header)
        # Skip unused frame
        size = id3_size_caculate(frame_header[:size_bytes], has_zero_bit: frame_header[:version] == 4)
        file_io.seek(size, IO::SEEK_CUR)
      end

      def invalid?
        true
      end
    end
  end
end
