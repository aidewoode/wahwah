# frozen_string_literal: true

module WahWah
  module Ogg
    # The Ogg page header has the following format:
    #
    #  0                   1                   2                   3
    #  0 1 2 3 4 5 6 7 8 9 0 1 2 3 4 5 6 7 8 9 0 1 2 3 4 5 6 7 8 9 0 1| Byte
    # +-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+
    # | capture_pattern: Magic number for page start "OggS"           | 0-3
    # +-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+
    # | version       | header_type   | granule_position              | 4-7
    # +-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+
    # |                                                               | 8-11
    # +-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+
    # |                               | bitstream_serial_number       | 12-15
    # +-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+
    # |                               | page_sequence_number          | 16-19
    # +-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+
    # |                               | CRC_checksum                  | 20-23
    # +-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+
    # |                               |page_segments  | segment_table | 24-27
    # +-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+
    # | ...                                                           | 28-
    # +-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+
    #
    #
    # The fields in the page header have the following meaning:
    #
    # 1. capture_pattern: a 4 Byte field that signifies the beginning of a
    #    page.  It contains the magic numbers:

    #          0x4f 'O'

    #          0x67 'g'

    #          0x67 'g'

    #          0x53 'S'

    #    It helps a decoder to find the page boundaries and regain
    #    synchronisation after parsing a corrupted stream.  Once the
    #    capture pattern is found, the decoder verifies page sync and
    #    integrity by computing and comparing the checksum.

    # 2. stream_structure_version: 1 Byte signifying the version number of
    #    the Ogg file format used in this stream (this document specifies
    #    version 0).

    # 3. header_type_flag: the bits in this 1 Byte field identify the
    #    specific type of this page.

    #    *  bit 0x01

    #       set: page contains data of a packet continued from the previous
    #          page

    #       unset: page contains a fresh packet

    #    *  bit 0x02

    #       set: this is the first page of a logical bitstream (bos)

    #       unset: this page is not a first page

    #    *  bit 0x04

    #       set: this is the last page of a logical bitstream (eos)

    #       unset: this page is not a last page

    # 4. granule_position: an 8 Byte field containing position information.
    #    For example, for an audio stream, it MAY contain the total number
    #    of PCM samples encoded after including all frames finished on this
    #    page.  For a video stream it MAY contain the total number of video
    #    frames encoded after this page.  This is a hint for the decoder
    #    and gives it some timing and position information.  Its meaning is
    #    dependent on the codec for that logical bitstream and specified in
    #    a specific media mapping.  A special value of -1 (in two's
    #    complement) indicates that no packets finish on this page.

    # 5. bitstream_serial_number: a 4 Byte field containing the unique
    #    serial number by which the logical bitstream is identified.

    # 6. page_sequence_number: a 4 Byte field containing the sequence
    #    number of the page so the decoder can identify page loss.  This
    #    sequence number is increasing on each logical bitstream
    #    separately.

    # 7. CRC_checksum: a 4 Byte field containing a 32 bit CRC checksum of
    #    the page (including header with zero CRC field and page content).
    #    The generator polynomial is 0x04c11db7.

    # 8. number_page_segments: 1 Byte giving the number of segment entries
    #    encoded in the segment table.

    # 9. segment_table: number_page_segments Bytes containing the lacing
    #    values of all segments in this page.  Each Byte contains one
    #    lacing value.
    class Page
      HEADER_SIZE = 27
      HEADER_FORMAT = "A4CxQx12C"

      attr_reader :segments, :granule_position

      def initialize(file_io)
        header_content = file_io.read(HEADER_SIZE)
        @capture_pattern, @version, @granule_position, page_segments = header_content.unpack(HEADER_FORMAT) if header_content.size >= HEADER_SIZE

        return unless valid?

        segment_table = file_io.read(page_segments).unpack("C" * page_segments)
        @segments = segment_table.map { |segment_length| file_io.read(segment_length) }
      end

      def valid?
        @capture_pattern == "OggS" && @version == 0
      end
    end
  end
end
