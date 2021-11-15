# frozen_string_literal: true

module WahWah
  module Ogg
    # From Ogg's perspective, packets can be of any arbitrary size.  A
    # specific media mapping will define how to group or break up packets
    # from a specific media encoder.  As Ogg pages have a maximum size of
    # about 64 kBytes, sometimes a packet has to be distributed over
    # several pages. To simplify that process, Ogg divides each packet
    # into 255 byte long chunks plus a final shorter chunk. These chunks
    # are called "Ogg Segments". They are only a logical construct and do
    # not have a header for themselves.
    class Packets
      include Enumerable

      def initialize(file_io)
        @file_io = file_io
      end

      def each
        @file_io.rewind

        packet = +""
        pages = Ogg::Pages.new(@file_io)

        pages.each do |page|
          page.segments.each do |segment|
            packet << segment

            # Ogg divides each packet into 255 byte long segments plus a final shorter segment.
            # So when segment length is less than 255 byte, it's the final segment.
            if segment.length < 255
              yield packet
              packet = +""
            end
          end
        end
      end
    end
  end
end
