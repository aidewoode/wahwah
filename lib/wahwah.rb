# frozen_string_literal: true

require 'wahwah/version'
require 'wahwah/errors'
require 'wahwah/tag'

module WahWah
  FORMATE_MAPPING = {
    Id3Tag: ['mp3'],
    OggTag: ['ogg', 'oga', 'opus'],
    WavTag: ['wav'],
    FlacTag: ['flac'],
    AsfTag: ['wma'],
    Mp4Tag: ['mp4', 'm4a']
  }.freeze

  def self.open(file_path)
    file_format = format(file_path)

    raise WahWahArgumentError, 'No supported format found' unless support_formats.include? file_format

    FORMATE_MAPPING.each do |tag, formats|
      break const_get(tag).new(file_path) if formats.include?(file_format)
    end
  end

  def self.format(file_path)
    File.extname(file_path).downcase.delete('.')
  end

  def self.support_formats
    FORMATE_MAPPING.values.flatten
  end
end
