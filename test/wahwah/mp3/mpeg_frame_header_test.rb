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
end
