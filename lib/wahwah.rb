# frozen_string_literal: true

require "stringio"
require "forwardable"
require "zlib"

require "wahwah/version"
require "wahwah/errors"
require "wahwah/helper"
require "wahwah/tag_delegate"
require "wahwah/lazy_read"
require "wahwah/tag"

require "wahwah/id3/v1"
require "wahwah/id3/v2"
require "wahwah/id3/v2_header"
require "wahwah/id3/frame"
require "wahwah/id3/frame_body"
require "wahwah/id3/text_frame_body"
require "wahwah/id3/genre_frame_body"
require "wahwah/id3/comment_frame_body"
require "wahwah/id3/image_frame_body"
require "wahwah/id3/lyrics_frame_body"

require "wahwah/mp3/mpeg_frame_header"
require "wahwah/mp3/xing_header"
require "wahwah/mp3/vbri_header"

require "wahwah/riff/chunk"

require "wahwah/flac/block"
require "wahwah/flac/streaminfo_block"

require "wahwah/ogg/page"
require "wahwah/ogg/pages"
require "wahwah/ogg/packets"
require "wahwah/ogg/vorbis_comment"
require "wahwah/ogg/vorbis_tag"
require "wahwah/ogg/opus_tag"
require "wahwah/ogg/flac_tag"

require "wahwah/asf/object"

require "wahwah/mp4/atom"

require "wahwah/mp3_tag"
require "wahwah/mp4_tag"
require "wahwah/ogg_tag"
require "wahwah/riff_tag"
require "wahwah/asf_tag"
require "wahwah/flac_tag"

module WahWah
  FORMATE_MAPPING = {
    Mp3Tag: ["mp3"],
    OggTag: ["ogg", "oga", "opus"],
    RiffTag: ["wav"],
    FlacTag: ["flac"],
    AsfTag: ["wma"],
    Mp4Tag: ["m4a"]
  }.freeze

  def self.open(file)
    opened = false
    # `Pathname`s respond to :read, but we still want to open them.
    if !file.respond_to?(:read) || file.respond_to?(:open)
      file = file.to_path if file.respond_to? :to_path
      file = file.to_str
      raise WahWahArgumentError, "File is not exists" unless File.exist? file
      raise WahWahArgumentError, "File is unreadable" unless File.readable? file
      raise WahWahArgumentError, "File is empty" unless File.size(file) > 0
      file = File.open file, "rb"
      opened = true
    end

    begin
      file_format = Helper.file_format(file)
      # Falling back on the extension only enables invalid files to be loaded
      # (for backwards API compatibility).
      file_format ||= file.respond_to?(:path) ? File.extname(file.path).downcase[1..] : nil
      raise WahWahArgumentError, "No supported format found" unless support_formats.include? file_format

      FORMATE_MAPPING.each do |tag, formats|
        break const_get(tag).new(file) if formats.include?(file_format)
      end
    ensure
      file.close if opened
    end
  end

  def self.support_formats
    FORMATE_MAPPING.values.flatten
  end
end
