# frozen_string_literal: true

module WahWah
  module ID3
    class V2 < Tag
      extend Forwardable

      def_delegators :@header, :major_version, :size, :has_extended_header?, :valid?

      def version
        "v2.#{major_version}"
      end

      private
        def parse
          @file_io.rewind
          @header = V2Header.new(@file_io)

          return unless valid?

          until end_of_tag? do
            frame = ID3::Frame.new(@file_io, major_version)
            (frame.skip; next) unless frame.valid?

            update_attribute(frame)
          end
        end

        def update_attribute(frame)
          name = frame.name

          case name
          when :comment
            # Because there may be more than one comment frame in each tag,
            # so push it into a array.
            @comments.push(frame.value)
          when :image
            # Because there may be more than one image frame in each tag,
            # so push it into a array.
            @images_data.push(frame); frame.skip
          when :track, :disc
            # Track and disc value may be extended with a "/" character
            # and a numeric string containing the total numer.
            count, total_count = frame.value.split('/', 2)
            instance_variable_set("@#{name}", count)
            instance_variable_set("@#{name}_total", total_count) unless total_count.nil?
          else
            instance_variable_set("@#{name}", frame.value)
          end
        end

        def end_of_tag?
          size <= @file_io.pos || file_size <= @file_io.pos
        end

        def parse_image_data(image_frame)
          image_frame.value
        end
    end
  end
end
