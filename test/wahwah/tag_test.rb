# frozen_string_literal: true

require "test_helper"

class WahWah::TagTest < Minitest::Test
  class SubTag < WahWah::Tag; end

  class SubTagWithParse < WahWah::Tag
    def parse
    end
  end

  def test_sub_class_not_implemented_parse_method
    assert_raises(WahWah::WahWahNotImplementedError) do
      File.open "test/files/id3v1.mp3" do |file|
        SubTag.new(file)
      end
    end
  end

  def test_have_necessary_attributes_method
    File.open "test/files/id3v1.mp3" do |file|
      tag = SubTagWithParse.new(file)

      assert_respond_to tag, :title
      assert_respond_to tag, :artist
      assert_respond_to tag, :album
      assert_respond_to tag, :albumartist
      assert_respond_to tag, :composer
      assert_respond_to tag, :comments
      assert_respond_to tag, :track
      assert_respond_to tag, :track_total
      assert_respond_to tag, :duration
      assert_respond_to tag, :file_size
      assert_respond_to tag, :genre
      assert_respond_to tag, :year
      assert_respond_to tag, :disc
      assert_respond_to tag, :disc_total
      assert_respond_to tag, :images
      assert_respond_to tag, :sample_rate
      assert_respond_to tag, :bit_depth
      assert_respond_to tag, :lyrics
    end
  end

  def test_initialized_attributes
    File.open "test/files/id3v1.mp3" do |file|
      tag = SubTagWithParse.new(file)

      assert_equal file.size, tag.file_size
      assert_equal [], tag.comments
      assert_equal [], tag.images
    end
  end

  def test_inspect
    File.open "test/files/id3v1.mp3" do |file|
      tag_inspect = SubTagWithParse.new(file).inspect

      WahWah::Tag::INTEGER_ATTRIBUTES.each do |attr_name|
        assert_includes tag_inspect, "#{attr_name}: "
      end
    end
  end

  def test_io_rewound_before_parse
    File.open "test/files/id3v1.mp3" do |file|
      file.read(10)
      tag = SubTagWithParse.new(file)
      assert tag.instance_variable_get(:@file_io).pos.zero?
    end
  end
end
