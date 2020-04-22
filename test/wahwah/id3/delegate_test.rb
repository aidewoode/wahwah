# frozen_string_literal: true

require 'test_helper'

class WahWah::ID3::DelegateTest < Minitest::Test
  class BaseTag
    attr_reader(*WahWah::ID3::Delegate::TAG_ATTRIBUTES)

    def initialize
      WahWah::ID3::Delegate::TAG_ATTRIBUTES.each do |attribute|
        instance_variable_set("@#{attribute}", attribute)
      end
    end
  end

  class Tag < BaseTag
    extend WahWah::ID3::Delegate
  end

  def setup
    @id3_tag = Object.new

    WahWah::ID3::Delegate::TAG_ATTRIBUTES.each do |attribute|
      @id3_tag.define_singleton_method(attribute) { "id3_#{attribute}" }
    end
  end

  def test_attibute_method_delegate_to_id3_tag
    tag = Tag.new
    tag.instance_variable_set(:@id3_tag, @id3_tag)

    WahWah::ID3::Delegate::TAG_ATTRIBUTES.each do |attribute|
      assert_equal "id3_#{attribute}", tag.send(attribute)
    end
  end

  def test_not_delegate_when_id3_tag_is_nil
    tag = Tag.new
    tag.instance_variable_set(:@id3_tag, nil)

    WahWah::ID3::Delegate::TAG_ATTRIBUTES.each do |attribute|
      assert_equal attribute, tag.send(attribute)
    end
  end

  def test_not_delegate_when_id3_tag_not_defined
    tag = Tag.new

    WahWah::ID3::Delegate::TAG_ATTRIBUTES.each do |attribute|
      assert_equal attribute, tag.send(attribute)
    end
  end
end
