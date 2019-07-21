# frozen_string_literal: true

require 'test_helper'
require 'fileutils'

class WahWahTest < Minitest::Test
  def test_not_exist_file
    assert_raises(WahWah::WahWahArgumentError) do
      WahWah.open('fake.mp3')
    end
  end

  def test_unreadable_file
    FileUtils.touch('file.mp3')
    File.chmod(100, 'file.mp3')

    assert !File.readable?('file.mp3')
    assert_raises(WahWah::WahWahArgumentError) do
      WahWah.open('file.mp3')
    end
  ensure
    File.chmod(770, 'file.mp3')
    FileUtils.remove_file('file.mp3')
  end

  def test_not_supported_formate
    FileUtils.touch('file.fake')

    assert_raises(WahWah::WahWahArgumentError) do
      WahWah.open('file.fake')
    end
  ensure
    FileUtils.remove_file('file.fake')
  end

  def test_id3v1_tag
    tag = WahWah.open('test/files/id3v1.mp3')

    assert_equal 'China Girl', tag.title
    assert_equal 'Iggy Pop', tag.artist
    assert_equal 'The Idiot', tag.album
    assert_equal '1977', tag.year
  end
end
