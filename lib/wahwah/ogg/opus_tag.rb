# frozen_string_literal: true

module WahWah
  module Ogg
    class OpusTag
      include VorbisComment

      attr_reader :sample_rate, :pre_skip, *COMMET_FIELD_MAPPING.values

      def initialize(identification_packet, comment_packet)
        # Identification packet structure:
        #
        # 1) "OpusHead"
        # 2) [version] = read 8 bits as unsigned integer
        # 3) [audio_channels] = read 8 bit as unsigned integer
        # 4) [pre_skip] = read 16 bits as unsigned little endian integer
        # 5) [input_sample_rate] = read 32 bits as unsigned little endian integer
        # 6) [output_gain] = read 16 bits as unsigned little endian integer
        # 7) [channel_mapping_family] = read 8 bit as unsigned integer
        # 8) [channel_mapping_table]
        @sample_rate = 48000
        @pre_skip = identification_packet[10..11].unpack('v').first

        comment_packet_id, comment_packet_body = [comment_packet[0..7], comment_packet[8..-1]]

        # Opus comment packet start with 'OpusTags'
        return unless comment_packet_id == 'OpusTags'

        parse_vorbis_comment(comment_packet_body)
      end
    end
  end
end
