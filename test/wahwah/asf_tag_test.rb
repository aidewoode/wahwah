# frozen_string_literal: true

require 'test_helper'

class WahWah::AsfTagTest < Minitest::Test
  def test_parse
    tag = WahWah::AsfTag.new('test/files/test.wma')

    assert_equal 'China Girl', tag.title
    assert_equal 'Iggy Pop', tag.artist
    assert_equal 'Iggy Pop', tag.albumartist
    assert_equal 'Iggy Pop', tag.composer
    assert_equal 'The Idiot', tag.album
    assert_equal '1977', tag.year
    assert_equal 'Rock', tag.genre
    assert_equal 5, tag.track
    assert_equal 1, tag.disc
    assert_equal ['Iggy Pop Rocks'], tag.comments
    assert_equal 8, tag.duration
    assert_equal 192, tag.bitrate
    assert_equal 44100, tag.sample_rate
    assert_equal 16, tag.bit_depth
    assert file_io_closed?(tag)
  end
end
