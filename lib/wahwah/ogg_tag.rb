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

    def packets
      @packets ||= Ogg::Packets.new(@file_io)
    end

    def pages
      @pages ||= Ogg::Pages.new(@file_io)
    end

    private
      def parse
        init_packet, comment_packet = packets.first(2)

        @tag = case true
               when init_packet.start_with?("\x01vorbis")
                 Ogg::VorbisTag.new(init_packet, comment_packet)
               when init_packet.start_with('OpusHead')
                 Ogg::OpusTag.new(init_packet, comment_packet)
               when init_packet.start_with('0x7FFLAC')
                 Ogg::FlacTag.new(init_packet, comment_packet)
        end
      end
  end
end
