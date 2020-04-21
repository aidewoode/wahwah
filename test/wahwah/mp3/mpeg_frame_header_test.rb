# frozen_string_literal: true

require 'test_helper'

class WahWah::Mp3::MpegFrameHeaderTest < Minitest::Test
  def test_prase
    content = StringIO.new("\x00\x00\x00\x00\xFF\xFB\x90d\x00\x00".b)
    header = WahWah::Mp3::MpegFrameHeader.new(content)

    assert_equal 'MPEG1', header.version
    assert_equal 'layer3', header.layer
    assert_equal 'MPEG1 layer3', header.kind
    assert_equal 'Joint Stereo', header.channel_mode
    assert_equal 128, header.frame_bitrate
    assert_equal 44100, header.sample_rate
    assert_equal 1152, header.samples_per_frame
  end

  def test_invalid_mpeg_frame_header
    content = StringIO.new("\x00\x00\x00\x00\x90d\x00\x00".b)
    header = WahWah::Mp3::MpegFrameHeader.new(content)

    assert !header.valid?
    assert_equal 0, header.position
    assert_nil header.version
    assert_nil header.layer
    assert_nil header.kind
    assert_nil header.channel_mode
    assert_nil header.frame_bitrate
    assert_nil header.sample_rate
    assert_nil header.samples_per_frame
  end
end
