# frozen_string_literal: true

require 'test_helper'

class WahWah::ID3::V2HeaderTest < Minitest::Test
  def test_header
    content = StringIO.new("ID3\x04\x00\x00\x00\x00\x00-".b)
    header = WahWah::ID3::V2Header.new(content)

    assert !header.has_extended_header?
    assert header.valid?
    assert_equal 55, header.size
    assert_equal 4, header.major_version
  end

  def test_has_extended_header
    content = StringIO.new("ID3\x04\x00@\x00\x00\x00 \x00\x00\x00\f\x01 \x05\x065uMx".b)
    header = WahWah::ID3::V2Header.new(content)

    assert header.has_extended_header?
    assert header.valid?
    assert_equal 42, header.size
    assert_equal 4, header.major_version
  end

  def test_invalid_header
    content = StringIO.new("id3\x04\x00\x00\x00\x00\x00-".b)
    header = WahWah::ID3::V2Header.new(content)

    assert !header.valid?
  end
end
