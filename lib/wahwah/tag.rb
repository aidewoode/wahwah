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
      :duration,
      :birtate,
      :file_size,
      :genre,
      :year,
      :disc,
      :disc_total,
      :images
    )

    def initialize(file_path)
      @file_size = File.size(file_path)
      @file_io = File.open(file_path)
      @comments = []
      @images = []

      parse if @file_size > 0
    end

    def parse
      raise WahWahNotImplementedError, 'The parse method is not implemented'
    end
  end
end
