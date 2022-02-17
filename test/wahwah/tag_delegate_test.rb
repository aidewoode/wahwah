# frozen_string_literal: true

require "test_helper"

class WahWah::TagDelegateTest < Minitest::Test
  class BaseTag
    attr_reader :title

    def initialize
      @title = "title"
    end
  end

  class Tag < BaseTag
    extend WahWah::TagDelegate
    tag_delegate :@tag, :title
  end

  def setup
    @tag = Object.new
    @tag.define_singleton_method(:title) { "tag_title" }
  end

  def test_attibute_method_delegate_to_tag
    tag = Tag.new
    tag.instance_variable_set(:@tag, @tag)

    assert_equal "tag_title", tag.title
  end

  def test_not_delegate_when_tag_is_nil
    tag = Tag.new
    tag.instance_variable_set(:@tag, nil)

    assert_equal "title", tag.title
  end

  def test_not_delegate_when_tag_not_defined
    tag = Tag.new
    assert_equal "title", tag.title
  end
end
