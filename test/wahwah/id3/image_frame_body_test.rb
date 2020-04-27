# frozen_string_literal: true

require 'test_helper'

class WahWah::ID3::ImageFrameBodyTest < Minitest::Test
  def test_v2_image_frame_body
    content = "\x00JPG\x00\x00\xFF\xD8\xFF\xE0\x00\x10JFIF\x00\x01\x02\x01\x00H\x00H\x00\x00\xFF\xE1\x1A\xE0Exif\x00\x00MM".b
    value = WahWah::ID3::ImageFrameBody.new(content, 2).value

    assert_equal 'image/jpeg', value[:mime_type]
    assert_equal :other, value[:type]
    assert_equal "\xFF\xD8\xFF\xE0\x00\x10JFIF\x00\x01\x02\x01\x00H\x00H\x00\x00\xFF\xE1\x1A\xE0Exif\x00\x00MM".b, value[:data]
  end

  def test_v3_4_image_frame_body
    content = "\x01image/jpeg\x00\x03\xFF\xFE\x00\x00\xFF\xD8\xFF\xE0\x00\x10JFIF\x00\x01\x01\x00\x00H\x00H\x00\x00\xFF\xE1\x00\xCAExif\x00\x00MM".b
    value = WahWah::ID3::ImageFrameBody.new(content, 4).value

    assert_equal 'image/jpeg', value[:mime_type]
    assert_equal :cover_front, value[:type]
    assert_equal "\xFF\xD8\xFF\xE0\x00\x10JFIF\x00\x01\x01\x00\x00H\x00H\x00\x00\xFF\xE1\x00\xCAExif\x00\x00MM".b, value[:data]
  end
end
