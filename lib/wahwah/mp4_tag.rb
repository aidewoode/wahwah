# frozen_string_literal: true

module WahWah
  class Mp4Tag < Tag
    META_ATOM_MAPPING = {
      "\xA9alb".b => :album,
      "\xA9ART".b => :artist,
      "\xA9cmt".b => :comment,
      "\xA9wrt".b => :composer,
      "\xA9day".b => :year,
      "\xA9gen".b => :genre,
      "\xA9nam".b => :title,
      'covr'.b => :image,
      'disk'.b => :disc,
      'trkn'.b => :track,
      'aART'.b => :albumartist
    }

    META_ATOM_DECODE_BY_TYPE = {
      0 => -> (data) { data },  # reserved
      1 => -> (data) { Helper.encode_to_utf8(data) }, # UTF-8
      2 => -> (data) { Helper.encode_to_utf8(data, 'UTF-16BE') }, # UTF-16BE
      3 => -> (data) { Helper.encode_to_utf8(data, 'SJIS') }, # SJIS

      13 => -> (data) { { data: data, mime_type: 'image/jpeg', type: :cover } },  # JPEG
      14 => -> (data) { { data: data, mime_type: 'image/png', type: :cover } },  # PNG

      21 => -> (data) { data.unpack('i>').first }, # Big endian signed integer
      22 => -> (data) { data.unpack('I>').first }, # Big endian unsigned integer
      23 => -> (data) { data.unpack('g').first }, # Big endian 32-bit floating point value
      24 => -> (data) { data.unpack('G').first }, # Big endian 64-bit floating point value

      65 => -> (data) { data.unpack('c').first }, # 8-bit signed integer
      66 => -> (data) { data.unpack('s>').first }, # Big-endian 16-bit signed integer
      67 => -> (data) { data.unpack('l>').first }, # Big-endian 32-bit signed integer
      74 => -> (data) { data.unpack('q>').first }, # Big-endian 64-bit signed integer

      75 => -> (data) { data.unpack('C').first }, # 8-bit unsigned integer
      76 => -> (data) { data.unpack('S>').first }, # Big-endian 16-bit unsigned integer
      77 => -> (data) { data.unpack('L>').first }, # Big-endian 32-bit unsigned integer
      78 => -> (data) { data.unpack('Q>').first } # Big-endian 64-bit unsigned integer
    }

    private
      def parse
        movie_atom = Mp4::Atom.find(@file_io, 'moov')
        return unless movie_atom.valid?

        parse_meta_list_atom movie_atom.find('udta', 'meta', 'ilst')
        parse_mvhd_atom movie_atom.find('mvhd')
        parse_stsd_atom movie_atom.find('trak', 'mdia', 'minf', 'stbl', 'stsd')
      end

      def parse_meta_list_atom(atom)
        return unless atom.valid?

        # The metadata item list atom holds a list of actual metadata values that are present in the metadata atom.
        # The metadata items are formatted as a list of items.
        # The metadata item list atom is of type ‘ilst’ and contains a number of metadata items, each of which is an atom.
        # each metadata item atom contains a Value Atom, to hold the value of the metadata item
        atom.children.each do |child_atom|
          attribute_name = META_ATOM_MAPPING[child_atom.type]

          # The value of the metadata item is expressed as immediate data in a value atom.
          # The value atom starts with two fields: a type indicator, and a locale indicator.
          # Both the type and locale indicators are four bytes long.
          # There may be multiple ‘value’ entries, using different type
          data_atom = child_atom.find('data')
          return unless data_atom.valid?

          data_type, data_value = data_atom.data.unpack('Nx4a*')
          encoded_data_value = META_ATOM_DECODE_BY_TYPE[data_type]&.call(data_value)

          next if attribute_name.nil? || encoded_data_value.nil?

          case attribute_name
          when :image
            @images.push(encoded_data_value)
          when :comment
            @comments.push(encoded_data_value)
          when :track, :disc
            count, total_count = encoded_data_value.unpack('x2nn')

            instance_variable_set("@#{attribute_name}", count) unless count.zero?
            instance_variable_set("@#{attribute_name}_total", total_count) unless total_count.zero?
          else
            instance_variable_set("@#{attribute_name}", encoded_data_value)
          end
        end
      end

      def parse_mvhd_atom(atom)
        return unless atom.valid?

        atom_data = StringIO.new(atom.data)
        version = atom_data.read(1).unpack('c').first

        # Skip flags
        atom_data.seek(3, IO::SEEK_CUR)

        if version == 0
          # Skip creation and modification time
          atom_data.seek(8, IO::SEEK_CUR)

          time_scale, duration = atom_data.read(8).unpack('l>l>')
        elsif version == 1
          # Skip creation and modification time
          atom_data.seek(16, IO::SEEK_CUR)

          time_scale, duration = atom_data.read(12).unpack('l>q>')
        end

        @duration = (duration / time_scale.to_f).round
      end

      def parse_stsd_atom(atom)
        return unless atom.valid?

        mp4a_atom = atom.find('mp4a')
        esds_atom = atom.find('esds')

        @sample_rate = mp4a_atom.data.unpack('x22I>').first if mp4a_atom.valid?
        @bitrate = esds_atom.data.unpack('x26I>').first / 1000 if esds_atom.valid?
      end
  end
end
