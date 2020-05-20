# frozen_string_literal: true

module WahWah
  class OggTag < Tag
    private
      def parse
        packets = Ogg::Packets.new(@file_io)
        init_packet, tag_packet = packets.first(2)

        @tag = if init_packet.start_with?("\001vorbis")
          Ogg::VorbisTag.new(init_packet, tag_packet)
        elsif init_packet.start_with('OpusHead')
          Ogg::OpusTag.new(init_packet, tag_packet)
        end
      end
  end
end
