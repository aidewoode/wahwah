# frozen_string_literal: true

require 'test_helper'

class WahWah::Ogg::VorbisCommentTest < Minitest::Test
  class Tag
    include WahWah::Ogg::VorbisComment

    def initialize(comment_content)
      parse_vorbis_comment(comment_content)
    end
  end

  def test_parse
    tag = Tag.new("\r\u0000\u0000\u0000libopus 1.3.1\t\u0000\u0000\u0000\u000F\u0000\u0000\u0000ALBUM=The Idiot\u0014\u0000\u0000\u0000ALBUMARTIST=Iggy Pop\u000F\u0000\u0000\u0000ARTIST=Iggy Pop\u0011\u0000\u0000\u0000COMPOSER=Iggy Pop\t\u0000\u0000\u0000DATE=1977\f\u0000\u0000\u0000DISCNUMBER=1\n\u0000\u0000\u0000GENRE=Rock\u0010\u0000\u0000\u0000TITLE=China Girl\r\u0000\u0000\u0000TRACKNUMBER=5".b)

    assert_equal 'China Girl', tag.instance_variable_get(:@title)
    assert_equal 'Iggy Pop', tag.instance_variable_get(:@artist)
    assert_equal 'Iggy Pop', tag.instance_variable_get(:@albumartist)
    assert_equal 'Iggy Pop', tag.instance_variable_get(:@composer)
    assert_equal 'The Idiot', tag.instance_variable_get(:@album)
    assert_equal '1977', tag.instance_variable_get(:@year)
    assert_equal 'Rock', tag.instance_variable_get(:@genre)
    assert_equal 5, tag.instance_variable_get(:@track)
    assert_equal 1, tag.instance_variable_get(:@disc)
  end

  def test_parse_lowercase_field_name
    tag = Tag.new("\r\u0000\u0000\u0000libopus 1.3.1\t\u0000\u0000\u0000\u000F\u0000\u0000\u0000Album=The Idiot\u0014\u0000\u0000\u0000Albumartist=Iggy Pop\u000F\u0000\u0000\u0000Artist=Iggy Pop\u0011\u0000\u0000\u0000Composer=Iggy Pop\t\u0000\u0000\u0000Date=1977\f\u0000\u0000\u0000Discnumber=1\n\u0000\u0000\u0000Genre=Rock\u0010\u0000\u0000\u0000Title=China Girl\r\u0000\u0000\u0000Tracknumber=5".b)

    assert_equal 'China Girl', tag.instance_variable_get(:@title)
    assert_equal 'Iggy Pop', tag.instance_variable_get(:@artist)
    assert_equal 'Iggy Pop', tag.instance_variable_get(:@albumartist)
    assert_equal 'Iggy Pop', tag.instance_variable_get(:@composer)
    assert_equal 'The Idiot', tag.instance_variable_get(:@album)
    assert_equal '1977', tag.instance_variable_get(:@year)
    assert_equal 'Rock', tag.instance_variable_get(:@genre)
    assert_equal 5, tag.instance_variable_get(:@track)
    assert_equal 1, tag.instance_variable_get(:@disc)
  end

  def test_invalid_encoding_comment
    tag = Tag.new("\x1D\x00\x00\x00Xiph.Org libVorbis I 20050304\x01\x00\x00\x00\x18\x00\x00\x00\x03\x00\x00\x00\x00\x00 @\x00\x00\x96B\x00\x00\x80?\x00@\x00 \x00\x00\x00@\x01".b)

    assert_nil tag.instance_variable_get(:@title)
    assert_nil tag.instance_variable_get(:@artist)
    assert_nil tag.instance_variable_get(:@albumartist)
    assert_nil tag.instance_variable_get(:@composer)
    assert_nil tag.instance_variable_get(:@album)
    assert_nil tag.instance_variable_get(:@year)
    assert_nil tag.instance_variable_get(:@genre)
    assert_nil tag.instance_variable_get(:@track)
    assert_nil tag.instance_variable_get(:@disc)
  end
end
