# frozen_string_literal: true

require 'test_helper'

class WahWah::Mp3::VbriHeaderTest < Minitest::Test
  def test_prase
    content = StringIO.new("VBRI\x00\x01\r\xB1\x00d\x00b\xDB\x91\x00\x00!:\x00\x84\x00\x01\x00\x02\x00@\x98\xB1\xBD\xA8\xBB6".b)
    header = WahWah::Mp3::VbriHeader.new(content)

    assert_equal 8506, header.frames_count
    assert_equal 6478737, header.bytes_count
    assert header.valid?
  end

  def test_invalid_header
    content = StringIO.new("\x00\x01VBRI\x00\x01\r\xB1\x00d\x00b\xDB\x91\x00\x00!:\x00\x84\x00\x01\x00\x02\x00@\x98\xB1\xBD\xA8\xBB6".b)
    header = WahWah::Mp3::VbriHeader.new(content)

    assert !header.valid?
  end
end
