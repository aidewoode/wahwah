# frozen_string_literal: true

module WahWah
  class Tag
    INTEGER_ATTRIBUTES = %i[disc disc_total track track_total]
    INSPECT_ATTRIBUTES = %i[title artist album albumartist composer track track_total genre year disc disc_total duration bitrate sample_rate bit_depth]

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
      :lyrics,
      :duration,
      :bitrate,
      :sample_rate,
      :bit_depth,
      :file_size
    )

    def initialize(file)
      # `Pathname`s respond to :read, but we still want to open them.
      opened = if file.respond_to?(:read) && !file.respond_to?(:open)
        @file_size = file.size
        @file_io = file
        false
      else
        @file_size = File.size(file)
        @file_io = File.open(file, "rb")
        true
      end

      begin
        @comments = []
        @images_data = []

        parse if @file_size > 0

        INTEGER_ATTRIBUTES.each do |attr_name|
          value = instance_variable_get("@#{attr_name}")&.to_i
          instance_variable_set("@#{attr_name}", value)
        end
      ensure
        @file_io.close if opened
      end
    end

    def inspect
      inspect_id = ::Kernel.format "%x", (object_id * 2)
      inspect_attributes_values = INSPECT_ATTRIBUTES.map { |attr_name| "#{attr_name}=#{send(attr_name)}" }.join(" ")

      "<#{self.class.name}:0x#{inspect_id} #{inspect_attributes_values}>"
    end

    def images
      return @images_data if @images_data.empty?

      @images_data.map do |data|
        parse_image_data(data)
      end
    end

    private

    def parse
      raise WahWahNotImplementedError, "The parse method is not implemented"
    end
  end
end
