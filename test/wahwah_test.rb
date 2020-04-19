# frozen_string_literal: true

require 'test_helper'
require 'fileutils'

class WahWahTest < Minitest::Test
  def test_not_exist_file
    assert_raises(WahWah::WahWahArgumentError) do
      WahWah.open('fake.mp3')
    end
  end

  def test_not_supported_formate
    FileUtils.touch('file.fake')

    assert_raises(WahWah::WahWahArgumentError) do
      WahWah.open('file.fake')
    end
  ensure
    FileUtils.remove_file('file.fake')
  end

  def test_path_name_as_argument
    assert_instance_of WahWah::Mp3Tag, WahWah.open(Pathname.new('test/files/id3v1.mp3'))
  end

  def test_support_formats
    assert_equal %w(mp3 ogg oga opus wav flac wma m4a).sort, WahWah.support_formats.sort
  end

  def test_return_correct_instance
    WahWah::FORMATE_MAPPING.values.flatten.each do |format|
      FileUtils.touch("empty.#{format}")
    end

    assert_instance_of WahWah::Mp3Tag, WahWah.open('empty.mp3')
    assert_instance_of WahWah::OggTag, WahWah.open('empty.ogg')
    assert_instance_of WahWah::OggTag, WahWah.open('empty.oga')
    assert_instance_of WahWah::OggTag, WahWah.open('empty.opus')
    assert_instance_of WahWah::RiffTag, WahWah.open('empty.wav')
    assert_instance_of WahWah::FlacTag, WahWah.open('empty.flac')
    assert_instance_of WahWah::AsfTag, WahWah.open('empty.wma')
    assert_instance_of WahWah::Mp4Tag, WahWah.open('empty.m4a')
  ensure
    WahWah::FORMATE_MAPPING.values.flatten.each do |format|
      FileUtils.remove_file("empty.#{format}")
    end
  end
end
