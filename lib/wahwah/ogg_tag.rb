# frozen_string_literal: true

module WahWah
  class OggTag < Tag
    extend TagDelegate

    tag_delegate :@tag,
      :title,
      :album,
      :albumartist,
      :track,
      :artist,
      :year,
      :genre,
      :disc,
      :composer

    def duration
      @duration ||= parse_duration
    end

    def bitrate
      @bitrate ||= parse_bitrate
    end

    private
      def packets
        @packets ||= Ogg::Packets.new(@file_io)
      end

      def pages
        @pages ||= Ogg::Pages.new(@file_io)
      end

      def parse
        identification_packet, comment_packet = packets.first(2)

        @overhead_packets_size = identification_packet.size + comment_packet.size

        @tag = case true
               when identification_packet.start_with?("\x01vorbis")
                 Ogg::VorbisTag.new(identification_packet, comment_packet)
               when identification_packet.start_with?('OpusHead')
                 Ogg::OpusTag.new(identification_packet, comment_packet)
               when identification_packet.start_with?("\x7FFLAC")
                 Ogg::FlacTag.new(identification_packet, comment_packet)
        end
      end

      def parse_duration
        return @tag.duration if @tag.respond_to? :duration

        last_page = pages.to_a.last
        pre_skip = @tag.respond_to?(:pre_skip) ? @tag.pre_skip : 0

        ((last_page.granule_position - pre_skip) / @tag.sample_rate.to_f).round
      end

      def parse_bitrate
        return @tag.bitrate if @tag.respond_to? :bitrate
        ((file_size - @overhead_packets_size) * 8.0 / duration / 1000).round
      end
  end
end
