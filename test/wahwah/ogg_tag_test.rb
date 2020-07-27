# frozen_string_literal: true

require 'test_helper'

class WahWah::OggTagTest < Minitest::Test
  def test_vorbis_tag_file
    tag = WahWah::OggTag.new('test/files/vorbis_tag.ogg')

    assert_instance_of WahWah::Ogg::VorbisTag, tag.instance_variable_get(:@tag)
    assert_equal 'China Girl', tag.title
    assert_equal 'Iggy Pop', tag.artist
    assert_equal 'Iggy Pop', tag.albumartist
    assert_equal 'Iggy Pop', tag.composer
    assert_equal 'The Idiot', tag.album
    assert_equal '1977', tag.year
    assert_equal 'Rock', tag.genre
    assert_equal 5, tag.track
    assert_equal 1, tag.disc
    assert_equal 8, tag.duration
    assert_equal 192, tag.bitrate
    assert_equal 44100, tag.sample_rate
    assert_nil tag.bit_depth
    assert file_io_closed?(tag)
  end

  def test_opus_tag_file
    tag = WahWah::OggTag.new('test/files/opus_tag.opus')

    assert_instance_of WahWah::Ogg::OpusTag, tag.instance_variable_get(:@tag)
    assert_equal 'China Girl', tag.title
    assert_equal 'Iggy Pop', tag.artist
    assert_equal 'Iggy Pop', tag.albumartist
    assert_equal 'Iggy Pop', tag.composer
    assert_equal 'The Idiot', tag.album
    assert_equal '1977', tag.year
    assert_equal 'Rock', tag.genre
    assert_equal 5, tag.track
    assert_equal 1, tag.disc
    assert_equal 8, tag.duration
    assert_equal 2, tag.bitrate
    assert_equal 48000, tag.sample_rate
    assert_nil tag.bit_depth
    assert file_io_closed?(tag)
  end

  def test_flac_tag_file
    tag = WahWah::OggTag.new('test/files/flac_tag.oga')

    assert_instance_of WahWah::Ogg::FlacTag, tag.instance_variable_get(:@tag)
    assert_equal 'China Girl', tag.title
    assert_equal 'Iggy Pop', tag.artist
    assert_equal 'Iggy Pop', tag.albumartist
    assert_equal 'Iggy Pop', tag.composer
    assert_equal 'The Idiot', tag.album
    assert_equal '1977', tag.year
    assert_equal 'Rock', tag.genre
    assert_equal 5, tag.track
    assert_equal 1, tag.disc
    assert_equal 8, tag.duration
    assert_equal 705, tag.bitrate
    assert_equal 44100, tag.sample_rate
    assert_equal 16, tag.bit_depth
    assert file_io_closed?(tag)
  end
end
