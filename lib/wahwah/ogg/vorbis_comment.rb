# frozen_string_literal: true

module WahWah
  module Ogg
    # Vorbis comment structure:
    #
    # 0) "\x03vorbis"
    # 1) [vendor\_length] = read an unsigned integer of 32 bits
    # 2) [vendor\_string] = read a UTF-8 vector as [vendor\_length] octets
    # 3) [user\_comment\_list\_length] = read an unsigned integer of 32 bits
    # 4) iterate [user\_comment\_list\_length] times {
    #      5) [length] = read an unsigned integer of 32 bits
    #      6) this iteration’s user comment = read a UTF-8 vector as [length] octets
    #    }
    # 7) [framing\_bit] = read a single bit as boolean
    # 8) if ( [framing\_bit] unset or end-of-packet ) then ERROR
    # 9) done.
    module VorbisComment
      COMMET_FIELD_MAPPING = {
        TITLE: :title,
        ALBUM: :album,
        ALBUMARTIST: :albumartist,
        TRACKNUMBER: :track,
        ARTIST: :artist,
        DATE: :year,
        GENRE: :genre,
        DISCNUMBER: :disc,
        COMPOSER: :composer
      }

      def parse_vorbis_comment(comment_packet)
        comment_packet = StringIO.new(comment_packet)

        id = comment_packet.read(7)
        return unless id == "\x03vorbis"

        vendor_length = comment_packet.read(4).unpack('V').first
        comment_packet.seek(vendor_length, IO::SEEK_CUR) # Skip vendor_string

        comment_list_length = comment_packet.read(4).unpack('V').first

        comment_list_length.times do
          comment_length = comment_packet.read(4).unpack('V').first
          comment = Helper.encode_to_utf8(comment_packet.read(comment_length))
          field_name, field_value = comment.split('=', 2)
          attr_name = COMMET_FIELD_MAPPING[field_name.to_sym]

          instance_variable_set("@#{attr_name}", field_value) unless attr_name.nil?
        end
      end
    end
  end
end