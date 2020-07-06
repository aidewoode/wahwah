# frozen_string_literal: true

require 'test_helper'

class WahWah::Mp4TagTest < Minitest::Test
  def test_parse
    tag = WahWah::Mp4Tag.new('test/files/test.m4a')
    image = tag.images.first

    assert_equal 'China Girl', tag.title
    assert_equal 'Iggy Pop', tag.artist
    assert_equal 'Iggy Pop', tag.albumartist
    assert_equal 'Iggy Pop', tag.composer
    assert_equal 'The Idiot', tag.album
    assert_equal '1977', tag.year
    assert_equal 'Rock', tag.genre
    assert_equal 5, tag.track
    assert_equal 8, tag.track_total
    assert_equal 1, tag.disc
    assert_equal 1, tag.disc_total
    assert_equal ['Iggy Pop Rocks'], tag.comments
    assert_equal 'image/jpeg', image[:mime_type]
    assert_equal :cover, image[:type]
    assert_equal binary_data('test/files/cover.jpeg'), image[:data].strip
    assert_equal 8, tag.duration
    assert_equal 128, tag.bitrate
    assert_equal 44100, tag.sample_rate
    assert_nil tag.bit_depth
  end
end
