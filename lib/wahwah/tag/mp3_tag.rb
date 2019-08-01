# frozen_string_literal: true

module WahWah
  class Mp3Tag < Tag
    include ID3::V1
    include ID3::V2

    def parse(file)
      if is_id3v1?(file)
        parse_id3v1(file)
      else
        parse_id3v2
      end
    end
  end
end
