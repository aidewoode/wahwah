# frozen_string_literal: true

require 'test_helper'

class WahWah::ID3::V2Test < Minitest::Test
  def test_parse
    content = StringIO.new("ID3\x04\x00\x00\x00\x00\x00-TIT2\x00\x00\x00\v\x00\x00\x03China GirlTRCK\x00\x00\x00\x02\x00\x00\x035TPOS\x00\x00\x00\x02\x00\x00\x031".b)
    tag = WahWah::ID3::V2.new(content)

    assert_equal content.size, tag.size
    assert_equal 'China Girl', tag.title
    assert_equal 5, tag.track
    assert_equal 1, tag.disc
    assert_nil tag.track_total
    assert_nil tag.disc_total
    assert !tag.has_extended_header?
    assert_equal 'v2.4', tag.version
  end

  def test_with_track_total_and_disc_total
    content = StringIO.new("ID3\x04\x00\x00\x00\x00\x00GTIT2\x00\x00\x00\x17\x00\x00\x01\xFF\xFEC\x00h\x00i\x00n\x00a\x00 \x00G\x00i\x00r\x00l\x00TRCK\x00\x00\x00\t\x00\x00\x01\xFF\xFE5\x00/\x008\x00TPOS\x00\x00\x00\t\x00\x00\x01\xFF\xFE1\x00/\x001\x00".b)
    tag = WahWah::ID3::V2.new(content)

    assert_equal content.size, tag.size
    assert_equal 'China Girl', tag.title
    assert_equal 5, tag.track
    assert_equal 1, tag.disc
    assert_equal 8, tag.track_total
    assert_equal 1, tag.disc_total
    assert !tag.has_extended_header?
    assert_equal 'v2.4', tag.version
  end

  def test_invalid_tag
    content = StringIO.new("id3TPE1\x00\x00\x00\x13\x00\x00\x01\xFF\xFEI\x00g\x00g\x00y\x00 \x00P\x00o\x00p\x00TIT2\x00\x00\x00\x17\x00\x00\x01\xFF\xFEC\x00h\x00i\x00n\x00a\x00 \x00G\x00i\x00r\x00l\x00TALB\x00\x00\x00\x15\x00\x00\x01\xFF\xFET\x00h\x00e\x00 \x00I\x00d\x00i\x00o\x00t\x00TPE2\x00\x00\x00\x13\x00\x00\x01\xFF\xFEI\x00g\x00g\x00y\x00 \x00P\x00o\x00p\x00TRCK\x00\x00\x00\t\x00\x00\x01\xFF\xFE5\x00/\x008\x00TPOS".b)
    tag = WahWah::ID3::V2.new(content)

    assert !tag.valid?
  end

  def test_extended_header_tag
    content = StringIO.new("ID3\x04\x00@\x00\x00\x00 \x00\x00\x00\f\x01 \x05\x065uMxTIT2\x00\x00\x00\n\x00\x01\x00\x00\x00\x06\x03title".b)

    tag = WahWah::ID3::V2.new(content)

    assert_equal content.size, tag.size
    assert_equal 'title', tag.title
    assert_equal 'v2.4', tag.version
    assert tag.has_extended_header?
  end
end
