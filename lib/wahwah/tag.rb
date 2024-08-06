# frozen_string_literal: true

module WahWah
  class Tag
    INTEGER_ATTRIBUTES = %i[disc disc_total track track_total]
    INSPECT_ATTRIBUTES = %i[
      title
      artist
      album
      albumartist
      composer
      comments
      track
      track_total
      genre
      year
      disc
      disc_total
      lyrics
      duration
      bitrate
      sample_rate
      bit_depth
      file_size
    ]

    attr_reader(*INSPECT_ATTRIBUTES)

    def initialize(io, from_path: false)
      @from_path = from_path
      @file_size = io.size
      @file_io = io

      @comments = []
      @images_data = []

      parse if @file_size > 0

      INTEGER_ATTRIBUTES.each do |attr_name|
        value = instance_variable_get("@#{attr_name}")&.to_i
        instance_variable_set("@#{attr_name}", value)
      end
    end

    def inspect
      inspect_id = ::Kernel.format "%x", (object_id * 2)
      inspect_attributes_values = INSPECT_ATTRIBUTES.map { |attr_name| "#{attr_name}: #{send(attr_name).inspect}" }.join(", ")

      "<#{self.class.name}:0x#{inspect_id} #{inspect_attributes_values}>"
    end

    def images
      return @images_data if @images_data.empty?

      @images ||= @images_data.map do |data|
        parse_image_data(data)
      end
    end

    private

    attr_accessor :from_path

    def parse
      raise WahWahNotImplementedError, "The parse method is not implemented"
    end
  end
end
