# frozen_string_literal: true

module WahWah
  module Ogg
    class FlacTag
      include VorbisComment
      include Flac::StreaminfoBlock

      attr_reader :bitrate, :duration, :sample_rate, :bit_depth, *COMMET_FIELD_MAPPING.values

      def initialize(identification_packet, comment_packet)
        # Identification packet structure:
        #
        # The one-byte packet type 0x7F
        # The four-byte ASCII signature "FLAC", i.e. 0x46, 0x4C, 0x41, 0x43
        # A one-byte binary major version number for the mapping, e.g. 0x01 for mapping version 1.0
        # A one-byte binary minor version number for the mapping, e.g. 0x00 for mapping version 1.0
        # A two-byte, big-endian binary number signifying the number of header (non-audio) packets, not including this one.
        # The four-byte ASCII native FLAC signature "fLaC" according to the FLAC format specification
        # The STREAMINFO metadata block for the stream.
        #
        # The first identification packet is followed by one or more header packets.
        # Each such packet will contain a single native FLAC metadata block.
        # The first of these must be a VORBIS_COMMENT block.

        id, streaminfo_block_data = identification_packet.unpack("x9A4A*")

        return unless id == "fLaC"
        streaminfo_block = Flac::Block.new(StringIO.new(streaminfo_block_data))
        vorbis_comment_block = Flac::Block.new(StringIO.new(comment_packet))

        parse_streaminfo_block(streaminfo_block.data)
        parse_vorbis_comment(vorbis_comment_block.data)
      end
    end
  end
end
