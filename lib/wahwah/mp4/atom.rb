# frozen_string_literal: true

module WahWah
  module Mp4
    class Atom
      prepend LazyRead

      VERSIONED_ATOMS = %w[meta stsd]
      FLAGGED_ATOMS = %w[stsd]
      HEADER_SIZE = 8
      HEADER_SIZE_FIELD_SIZE = 4
      EXTENDED_HEADER_SIZE = 8

      attr_reader :type

      def self.find(file_io, *atom_path)
        file_io.rewind

        atom_type = atom_path.shift

        until file_io.eof?
          atom = new(file_io)

          next unless atom.valid?
          file_io.seek(atom.size, IO::SEEK_CUR)
          next unless atom.type == atom_type

          return atom if atom_path.empty?
          return atom.find(*atom_path)
        end

        # Return empty atom if can not found
        new(StringIO.new(""))
      end

      # An atom header consists of the following fields:
      #
      # Atom size:
      # A 32-bit integer that indicates the size of the atom, including both the atom header and the atom’s contents,
      # including any contained atoms. Normally, the size field contains the actual size of the atom.
      #
      # Type:
      # A 32-bit integer that contains the type of the atom.
      # This can often be usefully treated as a four-character field with a mnemonic value .
      def initialize
        @size, @type = @file_io.read(HEADER_SIZE)&.unpack("Na4")

        # If the size field of an atom is set to 1, the type field is followed by a 64-bit extended size field,
        # which contains the actual size of the atom as a 64-bit unsigned integer.
        @size = @file_io.read(EXTENDED_HEADER_SIZE).unpack1("Q>") - EXTENDED_HEADER_SIZE if @size == 1

        # If the size field of an atom is set to 0, which is allowed only for a top-level atom,
        # designates the last atom in the file and indicates that the atom extends to the end of the file.
        @size = @file_io.size if @size == 0
        return unless valid?

        @size -= HEADER_SIZE
      end

      def valid?
        !@size.nil? && @size >= HEADER_SIZE
      end

      def find(*atom_path)
        child_atom_index = data.index(atom_path.first)

        # Return empty atom if can not found
        return self.class.new(StringIO.new("")) if child_atom_index.nil?

        # Because before atom type field there are 4 bytes of size field,
        # So the child_atom_index should reduce 4.
        self.class.find(StringIO.new(data[child_atom_index - HEADER_SIZE_FIELD_SIZE..]), *atom_path)
      end

      def children
        @children ||= parse_children_atoms
      end

      private

      def parse_children_atoms
        children_atoms = []
        atoms_data = data

        # Some atoms data contain extra content before child atom data.
        # So reduce those extra content to get child atom data.
        atoms_data = atoms_data[4..] if VERSIONED_ATOMS.include? type # Skip 4 bytes for version
        atoms_data = atoms_data[4..] if FLAGGED_ATOMS.include? type # Skip 4 bytes for flag
        atoms_data_io = StringIO.new(atoms_data)

        until atoms_data_io.eof?
          atom = self.class.new(atoms_data_io)
          children_atoms.push(atom)

          atom.skip
        end

        children_atoms
      end
    end
  end
end
