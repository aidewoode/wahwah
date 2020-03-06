# frozen_string_literal: true

module WahWah
  class Mp3Tag
    class << self
      def new(file_path)
        @file_io = File.open(file_path)

        if id3v2?
          ID3::V2.new(file_path)
        elsif id3v1?
          ID3::V1.new(file_path)
        end
      end

      def id3v1?
        @file_io.seek(-ID3::V1::TAG_SIZE, IO::SEEK_END)
        @file_io.read(3) == ID3::V1::TAG_ID
      end

      def id3v2?
        @file_io.rewind
        @file_io.read(3) == ID3::V2::TAG_ID
      end
    end
  end
end
