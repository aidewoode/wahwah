# frozen_string_literal: true

require "test_helper"

class WahWah::OggTagTest < Minitest::Test
  def test_vorbis_tag_file
    File.open "test/files/vorbis_tag.ogg" do |file|
      tag = WahWah::OggTag.new(file)

      assert_instance_of WahWah::Ogg::VorbisTag, tag.instance_variable_get(:@tag)
      assert_equal "China Girl", tag.title
      assert_equal "Iggy Pop", tag.artist
      assert_equal "Iggy Pop", tag.albumartist
      assert_equal "Iggy Pop", tag.composer
      assert_equal "The Idiot", tag.album
      assert_equal "1977", tag.year
      assert_equal "Rock", tag.genre
      assert_equal 5, tag.track
      assert_equal 1, tag.disc
      assert_equal 8.0, tag.duration
      assert_equal 192, tag.bitrate
      assert_equal 44100, tag.sample_rate
      assert_nil tag.bit_depth
      assert_equal "I'm feeling tragic like I'm Marlon Brando", tag.lyrics
    end
  end

  def test_opus_tag_file
    File.open "test/files/opus_tag.opus" do |file|
      tag = WahWah::OggTag.new(file)

      assert_instance_of WahWah::Ogg::OpusTag, tag.instance_variable_get(:@tag)
      assert_equal "China Girl", tag.title
      assert_equal "Iggy Pop", tag.artist
      assert_equal "Iggy Pop", tag.albumartist
      assert_equal "Iggy Pop", tag.composer
      assert_equal "The Idiot", tag.album
      assert_equal "1977", tag.year
      assert_equal "Rock", tag.genre
      assert_equal 5, tag.track
      assert_equal 1, tag.disc
      assert_equal 8.000020833333334, tag.duration
      assert_equal 2, tag.bitrate
      assert_equal 48000, tag.sample_rate
      assert_nil tag.bit_depth
      assert_equal "I'm feeling tragic like I'm Marlon Brando", tag.lyrics
    end
  end

  def test_flac_tag_file
    File.open "test/files/flac_tag.oga" do |file|
      tag = WahWah::OggTag.new(file)

      assert_instance_of WahWah::Ogg::FlacTag, tag.instance_variable_get(:@tag)
      assert_equal "China Girl", tag.title
      assert_equal "Iggy Pop", tag.artist
      assert_equal "Iggy Pop", tag.albumartist
      assert_equal "Iggy Pop", tag.composer
      assert_equal "The Idiot", tag.album
      assert_equal "1977", tag.year
      assert_equal "Rock", tag.genre
      assert_equal 5, tag.track
      assert_equal 1, tag.disc
      assert_equal 8.0, tag.duration
      assert_equal 705, tag.bitrate
      assert_equal 44100, tag.sample_rate
      assert_equal 16, tag.bit_depth
      assert_equal "I'm feeling tragic like I'm Marlon Brando", tag.lyrics
    end
  end

  def test_lazy_duration
    File.open("test/files/vorbis_tag.ogg", "rb") do |file|
      tag = WahWah::OggTag.new(file)
      assert tag.instance_variable_get(:@file_io).pos < file.size
      assert_nil tag.instance_variable_get(:@duration)

      tag.duration
      assert_equal 8.0, tag.instance_variable_get(:@duration)
    end
  end

  def test_lazy_bitrate
    File.open("test/files/vorbis_tag.ogg", "rb") do |file|
      tag = WahWah::OggTag.new(file)
      assert tag.instance_variable_get(:@file_io).pos < file.size
      assert_nil tag.instance_variable_get(:@bitrate)

      tag.bitrate
      assert_equal 192, tag.instance_variable_get(:@bitrate)
    end
  end

  def test_eager_duration_and_bitrate
    File.open("test/files/vorbis_tag.ogg", "rb") do |file|
      tag = WahWah::OggTag.new(file, from_path: true)

      assert_equal 8.0, tag.instance_variable_get(:@duration)
      assert_equal 192, tag.instance_variable_get(:@bitrate)
    end
  end
end
