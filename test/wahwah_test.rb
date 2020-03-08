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

  def test_id3v1_tag
    tag = WahWah.open('test/files/id3v1.mp3')

    assert_equal File.size('test/files/id3v1.mp3'), tag.file_size
    assert_equal 'China Girl', tag.title
    assert_equal 'Iggy Pop', tag.artist
    assert_equal 'The Idiot', tag.album
    assert_equal '1977', tag.year
    assert_equal 'Rock', tag.genre
    assert_equal 5, tag.track
    assert_equal ['Iggy Pop Rocks'], tag.comments
  end

  def test_id3v23_tag
    tag = WahWah.open('test/files/id3v23.mp3')

    assert_equal File.size('test/files/id3v23.mp3'), tag.file_size
    assert_equal 3, tag.major_version
    assert_equal 'China Girl', tag.title
    assert_equal 'Iggy Pop', tag.artist
    assert_equal 'Iggy Pop', tag.albumartist
    assert_equal 'Iggy Pop', tag.composer
    assert_equal 'The Idiot', tag.album
    assert_equal '1977', tag.year
    assert_equal 'Rock', tag.genre
    assert_equal 5, tag.track
    assert_equal 8, tag.track_total
    assert_equal 1, tag.disc
    assert_equal 1, tag.disc_total
    assert_equal ['Iggy Pop Rocks'], tag.comments
  end

  def test_id3v24_tag
    tag = WahWah.open('test/files/id3v24.mp3')

    assert_equal File.size('test/files/id3v24.mp3'), tag.file_size
    assert_equal 4, tag.major_version
    assert_equal 'China Girl', tag.title
    assert_equal 'Iggy Pop', tag.artist
    assert_equal 'Iggy Pop', tag.albumartist
    assert_equal 'Iggy Pop', tag.composer
    assert_equal 'The Idiot', tag.album
    assert_equal '1977', tag.year
    assert_equal 'Custom Genre', tag.genre
    assert_equal 5, tag.track
    assert_equal 8, tag.track_total
    assert_equal 1, tag.disc
    assert_equal 1, tag.disc_total
    assert_equal ['Iggy Pop Rocks'], tag.comments
  end
end
