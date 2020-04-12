# frozen_string_literal: true

module WahWah
  class Tag
    attr_reader(
      :title,
      :artist,
      :album,
      :albumartist,
      :composer,
      :comments,
      :track,
      :track_total,
      :genre,
      :year,
      :disc,
      :disc_total,
      :images,
      :duration,
      :bitrate,
      :file_size,
    )

    def initialize(file)
      if file.is_a?(IO) || file.is_a?(StringIO)
        @file_size = file.size
        @file_io = file
      else
        @file_size = File.size(file)
        @file_io = File.open(file)
      end

      @comments = []
      @images = []

      parse if @file_size > 0
    end

    def parse
      raise WahWahNotImplementedError, 'The parse method is not implemented'
    end
  end
end
