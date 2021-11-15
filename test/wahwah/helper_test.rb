# frozen_string_literal: true

require "test_helper"

class WahWah::HelperTest < Minitest::Test
  def test_encode_to_utf8
    test_string = "àáâãäåæçèéêëìíîï"
    iso_8859_1_string = test_string.encode("ISO-8859-1").b
    utf_16_string = test_string.encode("UTF-16").b
    utf_16_be_string = test_string.encode("UTF-16BE").b
    utf_8_string = test_string.encode("UTF-8").b

    assert_equal test_string, WahWah::Helper.encode_to_utf8(iso_8859_1_string, source_encoding: "ISO-8859-1")
    assert_equal test_string, WahWah::Helper.encode_to_utf8(utf_16_string, source_encoding: "UTF-16")
    assert_equal test_string, WahWah::Helper.encode_to_utf8(utf_16_be_string, source_encoding: "UTF-16BE")
    assert_equal test_string, WahWah::Helper.encode_to_utf8(utf_8_string)
    assert_equal "", WahWah::Helper.encode_to_utf8(utf_16_string)
  end

  def test_id3_size_caculate
    bits_string = "00000001000000010000000100000001"

    assert_equal 2113665, WahWah::Helper.id3_size_caculate(bits_string)
    assert_equal 16843009, WahWah::Helper.id3_size_caculate(bits_string, has_zero_bit: false)
  end

  def test_split_with_terminator
    test_string = "hi\x00there\x00!".b
    assert_equal ["hi", "there\x00!"], WahWah::Helper.split_with_terminator(test_string, 1)
  end

  def test_file_format
    assert_equal "mp3", WahWah::Helper.file_format("test_file.mp3")
    assert_equal "mp3", WahWah::Helper.file_format("test/test_file.mp3")
  end

  def test_byte_string_to_guid
    assert_equal "8CABDCA1-A947-11CF-8EE4-00C00C205365", WahWah::Helper.byte_string_to_guid("\xA1\xDC\xAB\x8CG\xA9\xCF\x11\x8E\xE4\x00\xC0\f Se".b)
  end
end
