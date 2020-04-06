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
end
