# frozen_string_literal: true

require "test_helper"

class WahWah::Mp4::AtomTest < Minitest::Test
  def test_find_atom
    io = File.open("test/files/udta_meta.m4a", "rb")
    atom = WahWah::Mp4::Atom.find(io, "moov", "udta")

    assert_equal "udta", atom.type
    assert_equal 5174, atom.size
  end

  def test_return_invalid_atom_when_not_found
    io = File.open("test/files/udta_meta.m4a", "rb")
    atom = WahWah::Mp4::Atom.find(io, "moov", "uuuu")

    assert_instance_of WahWah::Mp4::Atom, atom
    assert !atom.valid?
  end

  def test_parse
    content = StringIO.new("\x00\x00\x00gstsd\x00\x00\x00\x00\x00\x00\x00\x01\x00\x00\x00Wmp4a\x00\x00\x00\x00\x00\x00\x00\x01\x00\x00\x00\x00\x00\x00\x00\x00\x00\x02\x00\x10\x00\x00\x00\x00\xACD\x00\x00\x00\x00\x003esds\x00\x00\x00\x00\x03\x80\x80\x80\"\x00\x00\x00\x04\x80\x80\x80\x14@\x14\x00\x18\x00\x00\x00\b\x10\x00\x01\xF4\x00\x05\x80\x80\x80\x02\x12\x10\x06\x80\x80\x80\x01\x02".b)

    atom = WahWah::Mp4::Atom.new(content)
    assert_equal 95, atom.size
    assert_equal "stsd", atom.type
  end

  def test_invalid_atom
    content = StringIO.new("\x00\x00\x00\x00invalid".b)
    atom = WahWah::Mp4::Atom.new(content)

    assert !atom.valid?
  end

  def test_find_child_atom_from_atom
    io = File.open("test/files/udta_meta.m4a", "rb")
    atom = WahWah::Mp4::Atom.find(io, "moov", "trak", "mdia")
    child_atom = atom.find("minf", "stbl", "stsd")

    assert_equal "stsd", child_atom.type
    assert_equal 95, child_atom.size
  end

  def test_return_invalid_atom_when_not_found_from_atom
    io = File.open("test/files/udta_meta.m4a", "rb")
    atom = WahWah::Mp4::Atom.find(io, "moov", "trak", "mdia")
    child_atom = atom.find("minf", "stbl", "uuuu")

    assert_instance_of WahWah::Mp4::Atom, child_atom
    assert !child_atom.valid?
  end

  def test_get_atom_children_atoms
    io = File.open("test/files/udta_meta.m4a", "rb")
    atom = WahWah::Mp4::Atom.find(io, "moov", "udta", "meta")
    children = atom.children

    assert_equal 3, children.count
    assert_equal "hdlr", children[0].type
    assert_equal "ilst", children[1].type
    assert_equal "free", children[2].type
  end
end
