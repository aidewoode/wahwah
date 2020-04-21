# frozen_string_literal: true

module WahWah
  module ID3::Delegate
    TAG_ATTRIBUTES = %i(
      title
      artist
      album
      albumartist
      composer
      comments
      track
      track_total
      genre
      year
      disc
      disc_total
      images
    )

    def self.add_tag_attributes(attributes)
      attributes.each do |attr|
        define_method(attr) do
          return super() unless instance_variable_defined?(:@id3_tag) && !@id3_tag.nil?
          @id3_tag&.send(attr)
        end
      end
    end

    def self.included(_mod)
      add_tag_attributes TAG_ATTRIBUTES
    end
  end
end
