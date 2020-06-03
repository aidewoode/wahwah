# frozen_string_literal: true

require 'test_helper'

class WahWah::Flac::BlockTest < Minitest::Test
  def test_parse
    content = StringIO.new("\x00\x00\x00\"\x10\x00\x10\x00\x00\x00\x0E\x00\x00\x10\n\xC4B\xF0\x00\x05b d\xA9\xFD\x7Fl\xB0\xE1\xC9Z\xFE\xCD\xF3\xA3iqO".b)
    block = WahWah::Flac::Block.new(content)

    assert !block.is_last?
    assert_equal 'STREAMINFO', block.type
    assert_equal 34, block.size
    assert_equal "\x10\x00\x10\x00\x00\x00\x0E\x00\x00\x10\n\xC4B\xF0\x00\x05b d\xA9\xFD\x7Fl\xB0\xE1\xC9Z\xFE\xCD\xF3\xA3iqO".b, block.data
  end
end
