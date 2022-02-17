# frozen_string_literal: true

require "test_helper"

class WahWah::Mp3::XingHeaderTest < Minitest::Test
  def test_prase
    content = StringIO.new("Xing\x00\x00\x00\x0F\x00\x00\x014\x00\x00~\xC1\x00\x03\x05\b\n\r\x0F\x12\x14\x17\x19\x1C\x1E".b)
    header = WahWah::Mp3::XingHeader.new(content)

    assert_equal 308, header.frames_count
    assert_equal 32449, header.bytes_count
    assert header.valid?
  end

  def test_invalid_header
    content = StringIO.new("\x00\x00\x00Xing\x00\x00\x00\x0F\x00".b)
    header = WahWah::Mp3::XingHeader.new(content)

    assert !header.valid?
  end
end
