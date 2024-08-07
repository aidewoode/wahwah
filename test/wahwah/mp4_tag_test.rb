# frozen_string_literal: true

require "test_helper"

class WahWah::Mp4TagTest < Minitest::Test
  def test_parse_meta_on_udta_atom
    File.open "test/files/udta_meta.m4a" do |file|
      tag = WahWah::Mp4Tag.new(file)
      meta_atom = WahWah::Mp4::Atom.find(File.open(file.path), "moov", "udta", "meta")
      image = tag.images.first

      assert meta_atom.valid?
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
      assert_equal :cover, image[:type]
      assert_equal binary_data("test/files/cover.jpeg"), image[:data].strip
      assert_equal 8.057324263038549, tag.duration
      assert_equal 128, tag.bitrate
      assert_equal 44100, tag.sample_rate
      assert_equal "I'm feeling tragic like I'm Marlon Brando", tag.lyrics
      assert_nil tag.bit_depth
    end
  end

  def test_parse_meta_on_moov_atom
    File.open "test/files/moov_meta.m4a" do |file|
      tag = WahWah::Mp4Tag.new(file)
      meta_atom = WahWah::Mp4::Atom.find(File.open(file.path), "moov", "meta")
      udta_meta_atom = WahWah::Mp4::Atom.find(File.open(file.path), "moov", "udta", "meta")
      image = tag.images.first

      assert meta_atom.valid?
      assert !udta_meta_atom.valid?
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
      assert_equal :cover, image[:type]
      assert_equal binary_data("test/files/cover.jpeg"), image[:data].strip
      assert_equal 285.04816326530613, tag.duration
      assert_equal 256, tag.bitrate
      assert_equal 44100, tag.sample_rate
      assert_equal "I'm feeling tragic like I'm Marlon Brando", tag.lyrics
      assert_nil tag.bit_depth
    end
  end

  def test_parse_alac_encoded
    File.open "test/files/alac.m4a" do |file|
      tag = WahWah::Mp4Tag.new(file)
      image = tag.images.first

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
      assert_equal 3, tag.bitrate
      assert_equal 16, tag.bit_depth
      assert_equal 44100, tag.sample_rate
      assert_equal "I'm feeling tragic like I'm Marlon Brando", tag.lyrics
      assert_equal "image/jpeg", image[:mime_type]
      assert_equal :cover, image[:type]
      assert_equal binary_data("test/files/cover.jpeg"), image[:data].strip
    end
  end

  def test_parse_extended_header_atom
    File.open "test/files/extended_header_atom.m4a" do |file|
      tag = WahWah::Mp4Tag.new(file)
      meta_atom = WahWah::Mp4::Atom.find(File.open(file.path), "moov", "udta", "meta")
      image = tag.images.first

      assert meta_atom.valid?
      assert_equal "Test Recording 123", tag.title
      assert_equal "The Exemplars", tag.artist
      assert_equal "The Exemplars", tag.albumartist
      assert_equal "The Exemplars", tag.albumartist
      assert_equal "The Example Album", tag.album
      assert_equal "2024", tag.year
      assert_equal "Books & Spoken", tag.genre
      assert_equal 1, tag.track
      assert_equal 1, tag.track_total
      assert_equal 1, tag.disc
      assert_equal 1, tag.disc_total
      assert_equal ["This is an example comment"], tag.comments
      assert_equal "image/png", image[:mime_type]
      assert_equal :cover, image[:type]
      assert_equal 3.0399583333333333, tag.duration
      assert_equal 64, tag.bitrate
      assert_equal 48000, tag.sample_rate
      assert_equal "Test 123, Test 123.", tag.lyrics
      assert_nil tag.bit_depth
    end
  end
end
