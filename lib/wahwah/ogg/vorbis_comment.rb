# frozen_string_literal: true

module WahWah
  module Ogg
    # Vorbis comment structure:
    #
    # 1) [vendor_length] = read an unsigned integer of 32 bits
    # 2) [vendor_string] = read a UTF-8 vector as [vendor_length] octets
    # 3) [user_comment_list_length] = read an unsigned integer of 32 bits
    # 4) iterate [user_comment_list_length] times {
    #      5) [length] = read an unsigned integer of 32 bits
    #      6) this iteration’s user comment = read a UTF-8 vector as [length] octets
    #    }
    # 7) [framing_bit] = read a single bit as boolean
    # 8) if ( [framing_bit] unset or end-of-packet ) then ERROR
    # 9) done.
    module VorbisComment
      COMMET_FIELD_MAPPING = {
        'TITLE' => :title,
        'ALBUM' => :album,
        'ALBUMARTIST' => :albumartist,
        'TRACKNUMBER' => :track,
        'ARTIST' => :artist,
        'DATE' => :year,
        'GENRE' => :genre,
        'DISCNUMBER' => :disc,
        'COMPOSER' => :composer
      }

      def parse_vorbis_comment(comment_content)
        comment_content = StringIO.new(comment_content)

        vendor_length = comment_content.read(4).unpack('V').first
        comment_content.seek(vendor_length, IO::SEEK_CUR) # Skip vendor_string

        comment_list_length = comment_content.read(4).unpack('V').first

        comment_list_length.times do
          comment_length = comment_content.read(4).unpack('V').first
          comment = Helper.encode_to_utf8(comment_content.read(comment_length))
          field_name, field_value = comment.split('=', 2)
          attr_name = COMMET_FIELD_MAPPING[field_name&.upcase]

          field_value = field_value.to_i if %i(track disc).include? attr_name

          instance_variable_set("@#{attr_name}", field_value) unless attr_name.nil?
        end
      end
    end
  end
end
