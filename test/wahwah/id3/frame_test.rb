# frozen_string_literal: true

require 'test_helper'

class WahWah::ID3::FrameTest < Minitest::Test
  def test_v2_2_frame
    content = StringIO.new("TT2\x00\x00\x11\x00China Girl\x00".b)
    frame = WahWah::ID3::Frame.new(content, 2)

    assert frame.valid?
    assert !frame.compressed?
    assert !frame.data_length_indicator?
    assert_equal :title, frame.name
    assert_equal 'China Girl', frame.value
  end

  def test_v2_3_frame
    content = StringIO.new("TIT2\x00\x00\x00\x17\x00\x00\x01\xFF\xFEC\x00h\x00i\x00n\x00a\x00 \x00G\x00i\x00r\x00l\x00".b)
    frame = WahWah::ID3::Frame.new(content, 3)

    assert frame.valid?
    assert !frame.compressed?
    assert !frame.data_length_indicator?
    assert_equal :title, frame.name
    assert_equal 'China Girl', frame.value
  end

  def test_v2_4_frame
    content = StringIO.new("TIT2\x00\x00\x00\x17\x00\x00\x01\xFF\xFEC\x00h\x00i\x00n\x00a\x00 \x00G\x00i\x00r\x00l\x00".b)
    frame = WahWah::ID3::Frame.new(content, 4)

    assert frame.valid?
    assert !frame.compressed?
    assert !frame.data_length_indicator?
    assert_equal :title, frame.name
    assert_equal 'China Girl', frame.value
  end

  def test_invalid_frame
    content = StringIO.new("tit2\x00\x00\x00\x17\x00\x00\x01\xFF\xFEC\x00h\x00i\x00n\x00a\x00 \x00G\x00i\x00r\x00l\x00".b)
    frame = WahWah::ID3::Frame.new(content, 4)

    assert !frame.valid?
  end

  def test_data_length_indicator_frame
    content = StringIO.new("TIT2\x00\x00\x00\n\x00\x01\x00\x00\x00\x06\x03title\x00".b)
    frame = WahWah::ID3::Frame.new(content, 4)

    assert frame.valid?
    assert !frame.compressed?
    assert frame.data_length_indicator?
    assert_equal :title, frame.name
    assert_equal 'title', frame.value
  end

  def test_compressed_frame
    content = StringIO.new("TIT2\x00\x00\x00\"\x00\x80\x00\x00\x00\x9Bx\x9Cc\xFC\xFF\xCF\x99!\x83!\x93!\x8F!\x91A\x81\xC1\x1D\xC8*b\xC8a\x00\x00Q(\x05\x90".b)
    frame = WahWah::ID3::Frame.new(content, 3)

    assert frame.valid?
    assert frame.compressed?
    assert !frame.data_length_indicator?
    assert_equal :title, frame.name
    assert_equal 'China Girl', frame.value
  end
end
