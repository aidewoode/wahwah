# frozen_string_literal: true

require "test_helper"

class WahWah::ID3::TextFrameBodyTest < Minitest::Test
  def test_iso_8859_1_encode_text
    value = WahWah::ID3::TextFrameBody.new("\x00China Girl".b, 4).value

    assert_equal "China Girl", value
    assert_equal "UTF-8", value.encoding.name
  end

  def test_utf_16_encode_text
    value = WahWah::ID3::TextFrameBody.new("\x01\xFF\xFEC\x00h\x00i\x00n\x00a\x00 \x00G\x00i\x00r\x00l\x00".b, 4).value

    assert_equal "China Girl", value
    assert_equal "UTF-8", value.encoding.name
  end

  def test_utf_16be_encode_text
    value = WahWah::ID3::TextFrameBody.new("\x02\x00C\x00h\x00i\x00n\x00a\x00 \x00G\x00i\x00r\x00l".b, 4).value

    assert_equal "China Girl", value
    assert_equal "UTF-8", value.encoding.name
  end

  def test_utf_8_encode_text
    value = WahWah::ID3::TextFrameBody.new("\x03China Girl".b, 4).value

    assert_equal "China Girl", value
    assert_equal "UTF-8", value.encoding.name
  end
end
