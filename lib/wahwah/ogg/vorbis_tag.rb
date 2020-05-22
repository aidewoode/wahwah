# frozen_string_literal: true

module WahWah
  module Ogg
    class VorbisTag
      include VorbisComment

      attr_reader :bitrate, :sample_rate, *COMMET_FIELD_MAPPING.values

      def initialize(init_packet, comment_packet)
        # Init packet structure:
        # 0) \x01vorbis
        # 1) [vorbis_version] = read 32 bits as unsigned integer
        # 2) [audio_channels] = read 8 bit integer as unsigned
        # 3) [audio_sample_rate] = read 32 bits as unsigned integer
        # 4) [bitrate_maximum] = read 32 bits as signed integer
        # 5) [bitrate_nominal] = read 32 bits as signed integer
        # 6) [bitrate_minimum] = read 32 bits as signed integer
        # 7) [blocksize_0] = 2 exponent (read 4 bits as unsigned integer)
        # 8) [blocksize_1] = 2 exponent (read 4 bits as unsigned integer)
        # 9) [framing_flag] = read one bit
        @sample_rate, bitrate = init_packet[12, 12].unpack('Vx4V')
        @bitrate = bitrate / 1000

        parse_vorbis_comment(comment_packet)
      end
    end
  end
end
