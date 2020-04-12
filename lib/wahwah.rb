# frozen_string_literal: true

require 'wahwah/version'
require 'wahwah/errors'
require 'wahwah/helper'
require 'wahwah/tag'

require 'wahwah/id3/v1'
require 'wahwah/id3/v2'
require 'wahwah/id3/frame_generator'
require 'wahwah/id3/frame'
require 'wahwah/id3/text_frame'
require 'wahwah/id3/genre_frame'
require 'wahwah/id3/comment_frame'
require 'wahwah/id3/invalid_frame'
require 'wahwah/id3/image_frame'
require 'wahwah/id3/delegate'

require 'wahwah/mp3_tag'
require 'wahwah/mp4_tag'
require 'wahwah/ogg_tag'
require 'wahwah/riff_tag'
require 'wahwah/asf_tag'
require 'wahwah/flac_tag'


require 'wahwah/mp3/mpeg_frame_header'
require 'wahwah/mp3/xing_header'
require 'wahwah/mp3/vbri_header'

require 'wahwah/riff/chunk'

module WahWah
  FORMATE_MAPPING = {
    Mp3Tag: ['mp3'],
    OggTag: ['ogg', 'oga', 'opus'],
    RiffTag: ['wav'],
    FlacTag: ['flac'],
    AsfTag: ['wma'],
    Mp4Tag: ['m4a']
  }.freeze

  def self.open(file_path)
    file_path = file_path.to_path if file_path.respond_to? :to_path
    file_path = file_path.to_str

    file_format = format(file_path)

    raise WahWahArgumentError, 'File is not exists' unless File.exist? file_path
    raise WahWahArgumentError, 'File is unreadable' unless File.readable? file_path
    raise WahWahArgumentError, 'No supported format found' unless support_formats.include? file_format

    FORMATE_MAPPING.each do |tag, formats|
      break const_get(tag).new(file_path) if formats.include?(file_format)
    end
  end

  def self.support_formats
    FORMATE_MAPPING.values.flatten
  end

  private
    def self.format(file_path)
      File.extname(file_path).downcase.delete('.')
    end
end
