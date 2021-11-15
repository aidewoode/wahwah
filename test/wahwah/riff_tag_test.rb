# frozen_string_literal: true

require "test_helper"

class WahWah::RiffTagTest < Minitest::Test
  def test_id3_tag_file
    tag = WahWah::RiffTag.new("test/files/id3v2.wav")
    image = tag.images.first

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
    assert_equal 1411, tag.bitrate
    assert_equal "Stereo", tag.channel_mode
    assert_equal 44100, tag.sample_rate
    assert_equal 16, tag.bit_depth
    assert file_io_closed?(tag)
  end

  def test_riff_info_tag_file
    tag = WahWah::RiffTag.new("test/files/riff_info.wav")

    assert_equal "China Girl", tag.title
    assert_equal "Iggy Pop", tag.artist
    assert_equal "The Idiot", tag.album
    assert_equal "1977", tag.year
    assert_equal "Rock", tag.genre
    assert_equal ["Iggy Pop Rocks"], tag.comments
    assert_equal 8, tag.duration
    assert_equal 1411, tag.bitrate
    assert_equal "Stereo", tag.channel_mode
    assert_equal 44100, tag.sample_rate
    assert_equal 16, tag.bit_depth
    assert file_io_closed?(tag)
  end
end
