# frozen_string_literal: true

require 'test_helper'

class WahWah::LazyReadTest < Minitest::Test
  class Tag
    prepend WahWah::LazyRead

    def initialize
      @file_io.read(4)
      @size = 34
    end
  end

  def setup
    content = StringIO.new("\x00\x00\x00\"\x10\x00\x10\x00\x00\x00\x0E\x00\x00\x10\n\xC4B\xF0\x00\x05b d\xA9\xFD\x7Fl\xB0\xE1\xC9Z\xFE\xCD\xF3\xA3iqO".b)
    @tag = Tag.new(content)
  end

  def test_reposond_to_size_method
    assert_respond_to @tag, :size
  end

  def test_get_data
    assert_equal "\x10\x00\x10\x00\x00\x00\x0E\x00\x00\x10\n\xC4B\xF0\x00\x05b d\xA9\xFD\x7Fl\xB0\xE1\xC9Z\xFE\xCD\xF3\xA3iqO".b, @tag.data
  end

  def test_skip_data
    @tag.skip
    assert_equal 38, @tag.instance_variable_get(:@file_io).send(:pos)
  end
end
