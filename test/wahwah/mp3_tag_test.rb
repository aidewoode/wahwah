# frozen_string_literal: true

require "test_helper"

class WahWah::Mp3TagTest < Minitest::Test
  def test_id3v1_tag_file
    tag = WahWah::Mp3Tag.new("test/files/id3v1.mp3")

    assert !tag.id3v2?
    assert tag.is_vbr?
    assert_equal "v1", tag.id3_version
    assert_equal "China Girl", tag.title
    assert_equal "Iggy Pop", tag.artist
    assert_equal "The Idiot", tag.album
    assert_equal "1977", tag.year
    assert_equal "Rock", tag.genre
    assert_equal 5, tag.track
    assert_equal ["Iggy Pop Rocks"], tag.comments
    assert_equal 8, tag.duration
    assert_equal 32, tag.bitrate
    assert_equal "MPEG1", tag.mpeg_version
    assert_equal "layer3", tag.mpeg_layer
    assert_equal "Joint Stereo", tag.channel_mode
    assert_equal 44100, tag.sample_rate
    assert_nil tag.bit_depth
    assert file_io_closed?(tag)
  end

  def test_id3v22_tag_file
    tag = WahWah::Mp3Tag.new("test/files/id3v22.mp3")
    image = tag.images.first

    assert tag.id3v2?
    assert !tag.is_vbr?
    assert_equal "v2.2", tag.id3_version
    assert_equal "You Are The One", tag.title
    assert_equal "Shiny Toy Guns", tag.artist
    assert_nil tag.albumartist
    assert_nil tag.composer
    assert_equal "We Are Pilots", tag.album
    assert_equal "2006", tag.year
    assert_equal "Alternative", tag.genre
    assert_equal 1, tag.track
    assert_equal 11, tag.track_total
    assert_nil tag.disc
    assert_nil tag.disc_total
    assert_equal "0", tag.comments.first
    assert_equal "image/jpeg", image[:mime_type]
    assert_equal :other, image[:type]
    assert_equal binary_data("test/files/id3v22_cover.jpeg"), image[:data].strip
    assert_equal 0, tag.duration
    assert_equal 192, tag.bitrate
    assert_equal "MPEG1", tag.mpeg_version
    assert_equal "layer3", tag.mpeg_layer
    assert_equal "Stereo", tag.channel_mode
    assert_equal 44100, tag.sample_rate
    assert_nil tag.bit_depth
    assert file_io_closed?(tag)
  end

  def test_id3v23_tag_file
    tag = WahWah::Mp3Tag.new("test/files/id3v23.mp3")
    image = tag.images.first

    assert tag.id3v2?
    assert tag.is_vbr?
    assert_equal "v2.3", tag.id3_version
    assert_equal "China Girl", tag.title
    assert_equal "Iggy Pop", tag.artist
    assert_equal "Iggy Pop", tag.albumartist
    assert_equal "Iggy Pop", tag.composer
    assert_equal "The Idiot", tag.album
    assert_equal "1977", tag.year
    assert_equal "Rock", tag.genre
    assert_equal 5, tag.track
    assert_equal 8, tag.track_total
    assert_equal 1, tag.disc
    assert_equal 1, tag.disc_total
    assert_equal ["Iggy Pop Rocks"], tag.comments
    assert_equal "image/jpeg", image[:mime_type]
    assert_equal :cover_front, image[:type]
    assert_equal binary_data("test/files/cover.jpeg"), image[:data].strip
    assert_equal 8, tag.duration
    assert_equal 32, tag.bitrate
    assert_equal "MPEG1", tag.mpeg_version
    assert_equal "layer3", tag.mpeg_layer
    assert_equal "Joint Stereo", tag.channel_mode
    assert_equal 44100, tag.sample_rate
    assert_nil tag.bit_depth
    assert file_io_closed?(tag)
  end

  def test_id3v24_tag_file
    tag = WahWah::Mp3Tag.new("test/files/id3v24.mp3")
    image = tag.images.first

    assert tag.id3v2?
    assert tag.is_vbr?
    assert_equal "v2.4", tag.id3_version
    assert_equal "China Girl", tag.title
    assert_equal "Iggy Pop", tag.artist
    assert_equal "Iggy Pop", tag.albumartist
    assert_equal "Iggy Pop", tag.composer
    assert_equal "The Idiot", tag.album
    assert_equal "1977", tag.year
    assert_equal "Custom Genre", tag.genre
    assert_equal 5, tag.track
    assert_equal 8, tag.track_total
    assert_equal 1, tag.disc
    assert_equal 1, tag.disc_total
    assert_equal ["Iggy Pop Rocks"], tag.comments
    assert_equal "image/jpeg", image[:mime_type]
    assert_equal :cover_front, image[:type]
    assert_equal binary_data("test/files/cover.jpeg"), image[:data].strip
    assert_equal 8, tag.duration
    assert_equal 32, tag.bitrate
    assert_equal "MPEG1", tag.mpeg_version
    assert_equal "layer3", tag.mpeg_layer
    assert_equal "Joint Stereo", tag.channel_mode
    assert_equal 44100, tag.sample_rate
    assert_nil tag.bit_depth
    assert file_io_closed?(tag)
  end

  def test_id3v2_with_extented_tag_file
    tag = WahWah::Mp3Tag.new("test/files/id3v2_extended_header.mp3")

    assert tag.id3v2?
    assert !tag.is_vbr?
    assert_equal "v2.4", tag.id3_version
    assert_equal "title", tag.title
    assert_equal 0, tag.duration
    assert_equal 128, tag.bitrate
    assert_equal "MPEG2", tag.mpeg_version
    assert_equal "layer3", tag.mpeg_layer
    assert_equal "Single Channel", tag.channel_mode
    assert_equal 22050, tag.sample_rate
    assert_nil tag.bit_depth
    assert file_io_closed?(tag)
  end

  def test_vbri_header_file
    tag = WahWah::Mp3Tag.new("test/files/vbri_header.mp3")

    assert tag.id3v2?
    assert tag.is_vbr?
    assert_equal "v2.3", tag.id3_version
    assert_equal "China Girl", tag.title
    assert_equal "Iggy Pop", tag.artist
    assert_equal "Iggy Pop", tag.albumartist
    assert_equal "Iggy Pop", tag.composer
    assert_equal "The Idiot", tag.album
    assert_equal "1977", tag.year
    assert_equal "Rock", tag.genre
    assert_equal 5, tag.track
    assert_equal 8, tag.track_total
    assert_equal 1, tag.disc
    assert_equal 1, tag.disc_total
    assert_equal ["Iggy Pop Rocks"], tag.comments
    assert_equal 222, tag.duration
    assert_equal 233, tag.bitrate
    assert_equal "MPEG1", tag.mpeg_version
    assert_equal "layer3", tag.mpeg_layer
    assert_equal "Stereo", tag.channel_mode
    assert_equal 44100, tag.sample_rate
    assert_nil tag.bit_depth
    assert file_io_closed?(tag)
  end

  def test_invalid_id3_file
    tag = WahWah.open("test/files/invalid_id3.mp3")

    assert tag.invalid_id3?
    assert !tag.id3v2?
    assert !tag.is_vbr?
    assert_nil tag.id3_version
    assert_nil tag.title
    assert_nil tag.artist
    assert_nil tag.albumartist
    assert_nil tag.composer
    assert_nil tag.album
    assert_nil tag.year
    assert_nil tag.genre
    assert_nil tag.track
    assert_nil tag.track_total
    assert_nil tag.disc
    assert_nil tag.disc_total
    assert_equal [], tag.comments
    assert_nil tag.duration
    assert_equal 0, tag.bitrate
    assert_equal "MPEG1", tag.mpeg_version
    assert_equal "layer1", tag.mpeg_layer
    assert_equal "Stereo", tag.channel_mode
    assert_equal 44100, tag.sample_rate
    assert_nil tag.bit_depth
    assert file_io_closed?(tag)
  end

  def test_compressed_image_file
    tag = WahWah.open("test/files/compressed_image.mp3")
    image = tag.images.first

    assert_equal binary_data("test/files/compressed_cover.bmp"), image[:data].strip
    assert file_io_closed?(tag)
  end

  def test_incomplete_file
    tag = WahWah.open("test/files/incomplete.mp3")

    assert tag.invalid_id3?
    assert !tag.id3v2?
    assert !tag.is_vbr?
    assert_nil tag.id3_version
    assert_nil tag.title
    assert_nil tag.artist
    assert_nil tag.albumartist
    assert_nil tag.composer
    assert_nil tag.album
    assert_nil tag.year
    assert_nil tag.genre
    assert_nil tag.track
    assert_nil tag.track_total
    assert_nil tag.disc
    assert_nil tag.disc_total
    assert_equal [], tag.comments
    assert_nil tag.duration
    assert_nil tag.bitrate
    assert_nil tag.mpeg_version
    assert_nil tag.mpeg_layer
    assert_nil tag.channel_mode
    assert_nil tag.sample_rate
    assert_nil tag.bit_depth
    assert file_io_closed?(tag)
  end

  def test_invalid_encoding_string_file
    tag = WahWah.open("test/files/invalid_encoding_string.mp3")

    assert !tag.invalid_id3?
    assert tag.id3v2?
    assert !tag.is_vbr?
    assert_equal "v2.4", tag.id3_version
    assert_nil tag.title
    assert_equal "Paso a paso", tag.artist
    assert_equal "S/T", tag.album
    assert_nil tag.albumartist
    assert_nil tag.composer
    assert_equal "2003", tag.year
    assert_equal "Acustico", tag.genre
    assert_equal 1, tag.track
    assert_equal 21, tag.track_total
    assert_equal 0, tag.disc
    assert_equal 0, tag.disc_total
    assert_equal [], tag.comments
    assert_nil tag.duration
    assert_nil tag.bitrate
    assert_nil tag.mpeg_version
    assert_nil tag.mpeg_layer
    assert_nil tag.channel_mode
    assert_nil tag.sample_rate
    assert_nil tag.bit_depth
    assert file_io_closed?(tag)
  end

  def test_utf16_string_file
    tag = WahWah.open("test/files/utf16.mp3")

    assert !tag.invalid_id3?
    assert tag.id3v2?
    assert !tag.is_vbr?
    assert_equal "v2.3", tag.id3_version
    assert_equal "Lemonworld", tag.title
    assert_equal "The National", tag.artist
    assert_equal "High Violet", tag.album
    assert_nil tag.albumartist
    assert_nil tag.composer
    assert_equal "2010", tag.year
    assert_equal "Indie", tag.genre
    assert_equal 7, tag.track
    assert_equal 11, tag.track_total
    assert_nil tag.disc
    assert_nil tag.disc_total
    assert_equal ["Track 7"], tag.comments
    assert_nil tag.duration
    assert_nil tag.bitrate
    assert_nil tag.mpeg_version
    assert_nil tag.mpeg_layer
    assert_nil tag.channel_mode
    assert_nil tag.sample_rate
    assert_nil tag.bit_depth
    assert file_io_closed?(tag)
  end
end
