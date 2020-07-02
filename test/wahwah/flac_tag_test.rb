# frozen_string_literal: true

require 'test_helper'

class WahWah::FlacTagTest < Minitest::Test
  def test_vorbis_comment_tag_file
    tag = WahWah::FlacTag.new('test/files/vorbis_comment.flac')
    image = tag.images.first

    assert_equal 'China Girl', tag.title
    assert_equal 'Iggy Pop', tag.artist
    assert_equal 'Iggy Pop', tag.albumartist
    assert_equal 'Iggy Pop', tag.composer
    assert_equal 'The Idiot', tag.album
    assert_equal '1977', tag.year
    assert_equal 'Rock', tag.genre
    assert_equal 5, tag.track
    assert_equal 1, tag.disc
    assert_equal 8, tag.duration
    assert_equal 705, tag.bitrate
    assert_equal 44100, tag.sample_rate
    assert_equal 'image/jpeg', image[:mime_type]
    assert_equal :cover_front, image[:type]
    assert_equal binary_data('test/files/cover.jpeg'), image[:data].strip
  end

  def test_id3_header_tag_file
    tag = WahWah::FlacTag.new('test/files/id3_header.flac')

    assert_equal 'ID3', File.read('test/files/id3_header.flac', 3)
    assert_equal 'China Girl', tag.title
    assert_equal 'Iggy Pop', tag.artist
    assert_equal 'Iggy Pop', tag.albumartist
    assert_equal 'Iggy Pop', tag.composer
    assert_equal 'The Idiot', tag.album
    assert_equal '1977', tag.year
    assert_equal 'Rock', tag.genre
    assert_equal 5, tag.track
    assert_equal 1, tag.disc
    assert_equal 0, tag.duration
    assert_equal 705, tag.bitrate
    assert_equal 44100, tag.sample_rate
  end

  def test_invalid_tag_file
    tag = WahWah::FlacTag.new('test/files/invalid_tag.flac')

    assert_nil tag.title
    assert_nil tag.artist
    assert_nil tag.albumartist
    assert_nil tag.composer
    assert_nil tag.album
    assert_nil tag.year
    assert_nil tag.genre
    assert_nil tag.track
    assert_nil tag.disc
    assert_equal 4, tag.duration
    assert_equal 705, tag.bitrate
    assert_equal 44100, tag.sample_rate
  end
end
