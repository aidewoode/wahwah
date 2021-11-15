# frozen_string_literal: true

require "test_helper"

class WahWah::Ogg::OpusTagTest < Minitest::Test
  def test_parse
    identification_packet = "OpusHead\x01\x028\x01\x80\xBB\x00\x00\x00\x00\x00".b
    comment_packet = "OpusTags\r\u0000\u0000\u0000libopus 1.3.1\t\u0000\u0000\u0000\u000F\u0000\u0000\u0000ALBUM=The Idiot\u0014\u0000\u0000\u0000ALBUMARTIST=Iggy Pop\u000F\u0000\u0000\u0000ARTIST=Iggy Pop\u0011\u0000\u0000\u0000COMPOSER=Iggy Pop\t\u0000\u0000\u0000DATE=1977\f\u0000\u0000\u0000DISCNUMBER=1\n\u0000\u0000\u0000GENRE=Rock\u0010\u0000\u0000\u0000TITLE=China Girl\r\u0000\u0000\u0000TRACKNUMBER=5".b

    tag = WahWah::Ogg::OpusTag.new(identification_packet, comment_packet)

    assert_equal "China Girl", tag.title
    assert_equal "Iggy Pop", tag.artist
    assert_equal "Iggy Pop", tag.albumartist
    assert_equal "Iggy Pop", tag.composer
    assert_equal "The Idiot", tag.album
    assert_equal "1977", tag.year
    assert_equal "Rock", tag.genre
    assert_equal 5, tag.track
    assert_equal 1, tag.disc
    assert_equal 48000, tag.sample_rate
    assert_equal 312, tag.pre_skip
  end

  def test_invalid_comment_packet
    identification_packet = "OpusHead\x01\x028\x01\x80\xBB\x00\x00\x00\x00\x00".b
    comment_packet = "opustags\r\u0000\u0000\u0000libopus 1.3.1\t\u0000\u0000\u0000\u000F\u0000\u0000\u0000ALBUM=The Idiot\u0014\u0000\u0000\u0000ALBUMARTIST=Iggy Pop\u000F\u0000\u0000\u0000ARTIST=Iggy Pop\u0011\u0000\u0000\u0000COMPOSER=Iggy Pop\t\u0000\u0000\u0000DATE=1977\f\u0000\u0000\u0000DISCNUMBER=1\n\u0000\u0000\u0000GENRE=Rock\u0010\u0000\u0000\u0000TITLE=China Girl\r\u0000\u0000\u0000TRACKNUMBER=5".b

    tag = WahWah::Ogg::OpusTag.new(identification_packet, comment_packet)

    assert_nil tag.title
    assert_nil tag.artist
    assert_nil tag.albumartist
    assert_nil tag.composer
    assert_nil tag.album
    assert_nil tag.year
    assert_nil tag.genre
    assert_nil tag.track
    assert_nil tag.disc
    assert_equal 48000, tag.sample_rate
    assert_equal 312, tag.pre_skip
  end
end
