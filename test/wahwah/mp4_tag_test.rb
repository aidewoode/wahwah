# frozen_string_literal: true

require "test_helper"

class WahWah::Mp4TagTest < Minitest::Test
  def test_parse_meta_on_udta_atom
    file_path = "test/files/udta_meta.m4a"
    tag = WahWah::Mp4Tag.new(file_path)
    meta_atom = WahWah::Mp4::Atom.find(File.open(file_path), "moov", "udta", "meta")
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
    assert_nil tag.bit_depth
    assert file_io_closed?(tag)
  end

  def test_parse_meta_on_moov_atom
    file_path = "test/files/moov_meta.m4a"
    tag = WahWah::Mp4Tag.new(file_path)
    meta_atom = WahWah::Mp4::Atom.find(File.open(file_path), "moov", "meta")
    udta_meta_atom = WahWah::Mp4::Atom.find(File.open(file_path), "moov", "udta", "meta")
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
    assert_nil tag.bit_depth
    assert file_io_closed?(tag)
  end

  def test_parse_alac_encoded
    tag = WahWah::Mp4Tag.new("test/files/alac.m4a")
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
    assert_equal "image/jpeg", image[:mime_type]
    assert_equal :cover, image[:type]
    assert_equal binary_data("test/files/cover.jpeg"), image[:data].strip
    assert file_io_closed?(tag)
  end
end
