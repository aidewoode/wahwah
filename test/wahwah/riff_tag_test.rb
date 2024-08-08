# frozen_string_literal: true

require "test_helper"

class WahWah::RiffTagTest < Minitest::Test
  def test_id3_tag_file
    File.open "test/files/id3v2.wav" do |file|
      tag = WahWah::RiffTag.new(file)
      image = tag.images.first

      assert_equal "China Girl", tag.title
      assert_equal "Iggy Pop", tag.artist
      assert_equal "Iggy Pop", tag.albumartist
      assert_equal "Iggy Pop", tag.composer
      assert_equal "The Idiot", tag.album
      assert_equal "1977", tag.year
      assert_equal "Rock", tag.genre
      assert_equal 5, tag.track
      assert_equal 8, tag.track_total
      assert_equal 1, tag.disc
      assert_equal 1, tag.disc_total
      assert_equal ["Iggy Pop Rocks"], tag.comments
      assert_equal "image/jpeg", image[:mime_type]
      assert_equal :cover_front, image[:type]
      assert_equal binary_data("test/files/cover.jpeg"), image[:data].strip
      assert_equal 8.001133947554926, tag.duration
      assert_equal 1411, tag.bitrate
      assert_equal "Stereo", tag.channel_mode
      assert_equal 44100, tag.sample_rate
      assert_equal 16, tag.bit_depth
    end
  end

  def test_riff_info_tag_file
    File.open "test/files/riff_info.wav" do |file|
      tag = WahWah::RiffTag.new(file)

      assert_equal "China Girl", tag.title
      assert_equal "Iggy Pop", tag.artist
      assert_equal "The Idiot", tag.album
      assert_equal "1977", tag.year
      assert_equal "Rock", tag.genre
      assert_equal ["Iggy Pop Rocks"], tag.comments
      assert_equal 8.001133947554926, tag.duration
      assert_equal 1411, tag.bitrate
      assert_equal "Stereo", tag.channel_mode
      assert_equal 44100, tag.sample_rate
      assert_equal 16, tag.bit_depth
    end
  end

  def test_tag_that_riff_chunk_without_data_chunk
    File.open "test/files/riff_chunk_without_data_chunk.wav" do |file|
      tag = WahWah::RiffTag.new(file)

      assert_equal "China Girl", tag.title
      assert_equal "Iggy Pop", tag.artist
      assert_equal "The Idiot", tag.album
      assert_equal "1977", tag.year
      assert_equal "Rock", tag.genre
      assert_equal ["Iggy Pop Rocks"], tag.comments
      assert_equal 8, tag.duration.round
      assert_equal 1411, tag.bitrate
      assert_equal "Stereo", tag.channel_mode
      assert_equal 44100, tag.sample_rate
      assert_equal 16, tag.bit_depth
    end
  end

  def test_tag_works_with_file_missing_extension
    blob_data = binary_data("test/files/id3v2.wav")

    Tempfile.create("temp-audio-file", binmode: true) do |temp_file|
      temp_file.write blob_data
      tag = WahWah::RiffTag.new(temp_file)

      assert_equal "China Girl", tag.title
      assert_equal "Iggy Pop", tag.artist
      assert_equal "The Idiot", tag.album
      assert_equal "1977", tag.year
      assert_equal "Rock", tag.genre
      assert_equal ["Iggy Pop Rocks"], tag.comments
      assert_equal 8.001133947554926, tag.duration
      assert_equal 1411, tag.bitrate
      assert_equal "Stereo", tag.channel_mode
      assert_equal 44100, tag.sample_rate
      assert_equal 16, tag.bit_depth
    end
  end
end
