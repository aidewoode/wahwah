# frozen_string_literal: true

require 'test_helper'

class WahWah::ID3::CommentFrameBodyTest < Minitest::Test
  def test_iso_8859_1_encode_comment
    value = WahWah::ID3::CommentFrameBody.new("\x00eng\x00Iggy Pop Rocks".b, 4).value

    assert_equal 'Iggy Pop Rocks', value
    assert_equal 'UTF-8', value.encoding.name
  end

  def test_utf_16_encode_comment
    value = WahWah::ID3::CommentFrameBody.new("\x01eng\xFF\xFE\x00\x00\xFF\xFEI\x00g\x00g\x00y\x00 \x00P\x00o\x00p\x00 \x00R\x00o\x00c\x00k\x00s\x00".b, 4).value

    assert_equal 'Iggy Pop Rocks', value
    assert_equal 'UTF-8', value.encoding.name
  end

  def test_utf_16be_encode_comment
    value = WahWah::ID3::CommentFrameBody.new("\x02eng\x00\x00\x00I\x00g\x00g\x00y\x00 \x00P\x00o\x00p\x00 \x00R\x00o\x00c\x00k\x00s".b, 4).value

    assert_equal 'Iggy Pop Rocks', value
    assert_equal 'UTF-8', value.encoding.name
  end

  def test_utf_8_encode_comment
    value = WahWah::ID3::CommentFrameBody.new("\x03eng\x00Iggy Pop Rocks".b, 4).value

    assert_equal 'Iggy Pop Rocks', value
    assert_equal 'UTF-8', value.encoding.name
  end
end
