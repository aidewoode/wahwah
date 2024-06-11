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
      :composer,
      :sample_rate,
      :lyrics

    # Oggs require reading to the end of the file in order to calculate their
    # duration (as it's not stored in any header or metadata). Thus, if the
    # IO like object supplied to WahWah is a streaming download, getting the
    # duration would download the entire audio file, which may not be
    # desirable. Making it lazy in this manner allows the user to avoid that.
    def duration
      @duration ||= parse_duration
    end

    # Requires duration to calculate, so lazy as well.
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
      return if identification_packet.nil? || comment_packet.nil?

      @overhead_packets_size = identification_packet.size + comment_packet.size

      @tag = if identification_packet.start_with?("\x01vorbis")
        Ogg::VorbisTag.new(identification_packet, comment_packet)
      elsif identification_packet.start_with?("OpusHead")
        Ogg::OpusTag.new(identification_packet, comment_packet)
      elsif identification_packet.start_with?("\x7FFLAC")
        Ogg::FlacTag.new(identification_packet, comment_packet)
      end

      # Eagerly calculate duration and bitrate when open from path
      if from_path
        @duration = parse_duration
        @bitrate = parse_bitrate
      end

      @bit_depth = parse_bit_depth
    end

    def parse_duration
      return @tag.duration if @tag.respond_to? :duration

      last_page = pages.to_a.last
      pre_skip = @tag.respond_to?(:pre_skip) ? @tag.pre_skip : 0

      (last_page.granule_position - pre_skip) / @tag.sample_rate.to_f
    end

    def parse_bitrate
      return @tag.bitrate if @tag.respond_to? :bitrate
      ((file_size - @overhead_packets_size) * 8.0 / duration / 1000).round
    end

    def parse_bit_depth
      @tag.bit_depth if @tag.respond_to? :bit_depth
    end
  end
end
