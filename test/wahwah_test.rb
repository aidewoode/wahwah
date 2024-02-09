# frozen_string_literal: true

require "test_helper"
require "fileutils"

class WahWahTest < Minitest::Test
  def test_not_exist_file
    assert_raises(WahWah::WahWahArgumentError) do
      WahWah.open("fake.mp3")
    end
  end

  def test_not_supported_formate
    assert_raises(WahWah::WahWahArgumentError) do
      WahWah.open("test/files/cover.jpeg")
    end
  end

  def test_empty_file
    assert_raises(WahWah::WahWahArgumentError) do
      WahWah.open("test/files/empty.mp3")
    end
  end

  def test_path_name_as_argument
    assert_instance_of WahWah::Mp3Tag, WahWah.open(Pathname.new("test/files/id3v1.mp3"))
  end

  def test_opened_file_as_argument
    File.open "test/files/id3v1.mp3", "rb" do |file|
      assert_instance_of WahWah::Mp3Tag, WahWah.open(file)
    end
  end

  def test_support_formats
    assert_equal %w[mp3 ogg oga opus wav flac wma m4a].sort, WahWah.support_formats.sort
  end

  def test_return_correct_instance
    WahWah::FORMATE_MAPPING.values.flatten.each do |format|
      FileUtils.touch("invalid.#{format}")
      `echo 'te' > invalid.#{format}`
    end

    assert_instance_of WahWah::Mp3Tag, WahWah.open("invalid.mp3")
    assert_instance_of WahWah::OggTag, WahWah.open("invalid.ogg")
    assert_instance_of WahWah::OggTag, WahWah.open("invalid.oga")
    assert_instance_of WahWah::OggTag, WahWah.open("invalid.opus")
    assert_instance_of WahWah::RiffTag, WahWah.open("invalid.wav")
    assert_instance_of WahWah::FlacTag, WahWah.open("invalid.flac")
    assert_instance_of WahWah::AsfTag, WahWah.open("invalid.wma")
    assert_instance_of WahWah::Mp4Tag, WahWah.open("invalid.m4a")
  ensure
    WahWah::FORMATE_MAPPING.values.flatten.each do |format|
      FileUtils.remove_file("invalid.#{format}")
    end
  end
end
