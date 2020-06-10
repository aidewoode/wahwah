# frozen_string_literal: true

require 'test_helper'

class WahWah::Ogg::FlacTagTest < Minitest::Test
  def test_parse
    identification_packet = "\x7FFLAC\x01\x00\x00\x02fLaC\x00\x00\x00\"\x10\x00\x10\x00\x00\x00\x0E\x00\x00\x10\n\xC4B\xF0\x00\x05b d\xA9\xFD\x7Fl\xB0\xE1\xC9Z\xFE\xCD\xF3\xA3iqO".b
    comment_packet = "\x04\x00\x00\xCB \x00\x00\x00reference libFLAC 1.3.2 20170101\t\x00\x00\x00\x0F\x00\x00\x00ALBUM=The Idiot\x14\x00\x00\x00ALBUMARTIST=Iggy Pop\x0F\x00\x00\x00ARTIST=Iggy Pop\x11\x00\x00\x00COMPOSER=Iggy Pop\t\x00\x00\x00DATE=1977\f\x00\x00\x00DISCNUMBER=1\n\x00\x00\x00GENRE=Rock\x10\x00\x00\x00TITLE=China Girl\r\x00\x00\x00TRACKNUMBER=5".b

    tag = WahWah::Ogg::FlacTag.new(identification_packet, comment_packet)

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
  end

  def test_invalid_identification_packet
    identification_packet = "\x7FFLAC\x01\x00\x00\x02flac\x00\x00\x00\"\x10\x00\x10\x00\x00\x00\x0E\x00\x00\x10\n\xC4B\xF0\x00\x05b d\xA9\xFD\x7Fl\xB0\xE1\xC9Z\xFE\xCD\xF3\xA3iqO".b
    comment_packet = "\x04\x00\x00\xCB \x00\x00\x00reference libFLAC 1.3.2 20170101\t\x00\x00\x00\x0F\x00\x00\x00ALBUM=The Idiot\x14\x00\x00\x00ALBUMARTIST=Iggy Pop\x0F\x00\x00\x00ARTIST=Iggy Pop\x11\x00\x00\x00COMPOSER=Iggy Pop\t\x00\x00\x00DATE=1977\f\x00\x00\x00DISCNUMBER=1\n\x00\x00\x00GENRE=Rock\x10\x00\x00\x00TITLE=China Girl\r\x00\x00\x00TRACKNUMBER=5".b

    tag = WahWah::Ogg::FlacTag.new(identification_packet, comment_packet)

    assert_nil tag.title
    assert_nil tag.artist
    assert_nil tag.albumartist
    assert_nil tag.composer
    assert_nil tag.album
    assert_nil tag.year
    assert_nil tag.genre
    assert_nil tag.track
    assert_nil tag.disc
    assert_nil tag.duration
    assert_nil tag.bitrate
    assert_nil tag.sample_rate
  end
end
