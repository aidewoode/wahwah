# frozen_string_literal: true

module WahWah
  module Ogg
    class VorbisTag
      include VorbisComment

      attr_reader :bitrate, :sample_rate, *COMMET_FIELD_MAPPING.values

      def initialize(identification_packet, comment_packet)
        # Identification packet structure:
        #
        # 1) "\x01vorbis"
        # 2) [vorbis_version] = read 32 bits as unsigned integer
        # 3) [audio_channels] = read 8 bit integer as unsigned
        # 4) [audio_sample_rate] = read 32 bits as unsigned integer
        # 5) [bitrate_maximum] = read 32 bits as signed integer
        # 6) [bitrate_nominal] = read 32 bits as signed integer
        # 7) [bitrate_minimum] = read 32 bits as signed integer
        # 8) [blocksize_0] = 2 exponent (read 4 bits as unsigned integer)
        # 9) [blocksize_1] = 2 exponent (read 4 bits as unsigned integer)
        # 10) [framing_flag] = read one bit
        @sample_rate, bitrate = identification_packet[12, 12].unpack('Vx4V')
        @bitrate = bitrate / 1000

        comment_packet_id, comment_packet_body = [comment_packet[0..6], comment_packet[7..-1]]

        # Vorbis comment packet start with "\x03vorbis"
        return unless comment_packet_id == "\x03vorbis"

        parse_vorbis_comment(comment_packet_body)
      end
    end
  end
end
