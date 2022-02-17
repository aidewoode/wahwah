# frozen_string_literal: true

require "test_helper"

class WahWah::Ogg::PageTest < Minitest::Test
  def test_parse
    content = StringIO.new("OggS\u0000\u0002\u0000\u0000\u0000\u0000\u0000\u0000\u0000\u0000'\xBD\xAA\xC7\u0000\u0000\u0000\u0000\u0018\u0012\xA8\n\u0001\u001E\u0001vorbis\u0000\u0000\u0000\u0000\u0002D\xAC\u0000\u0000\u0000\u0000\u0000\u0000\u0000\xEE\u0002\u0000\u0000\u0000\u0000\u0000\xB8\u0001".b)
    page = WahWah::Ogg::Page.new(content)

    assert page.valid?
    assert_equal 0, page.granule_position
    assert_equal ["\x01vorbis\x00\x00\x00\x00\x02D\xAC\x00\x00\x00\x00\x00\x00\x00\xEE\x02\x00\x00\x00\x00\x00\xB8\x01".b], page.segments
  end

  def test_invalid_page
    content = StringIO.new("oggs\u0000\u0002\u0000\u0000\u0000\u0000\u0000\u0000\u0000\u0000'\xBD\xAA\xC7\u0000\u0000\u0000\u0000\u0018\u0012\xA8\n\u0001\u001E\u0001vorbis\u0000\u0000\u0000\u0000\u0002D\xAC\u0000\u0000\u0000\u0000\u0000\u0000\u0000\xEE\u0002\u0000\u0000\u0000\u0000\u0000\xB8\u0001".b)
    page = WahWah::Ogg::Page.new(content)

    assert !page.valid?
  end
end
