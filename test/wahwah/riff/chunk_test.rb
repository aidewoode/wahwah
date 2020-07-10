# frozen_string_literal: true

require 'test_helper'

class WahWah::Riff::ChunkTest < Minitest::Test
  def test_normal_chunk
    content = StringIO.new("fmt \x10\x00\x00\x00\x01\x00\x02\x00D\xAC\x00\x00\x10\xB1\x02\x00\x04\x00\x10\x00".b)
    chunk = WahWah::Riff::Chunk.new(content)

    assert_equal 'fmt', chunk.id
    assert_equal 16, chunk.size
    assert_nil chunk.type
  end

  def test_riff_and_list_chunk
    riff_chunk_content = StringIO.new("RIFFX\x89\x15\x00WAVE".b)
    list_chunk_content = StringIO.new("LIST\xAC\x00\x00\x00INFO".b)

    riff_chunk = WahWah::Riff::Chunk.new(riff_chunk_content)
    list_chunk = WahWah::Riff::Chunk.new(list_chunk_content)

    assert_equal 'RIFF', riff_chunk.id
    assert_equal 'LIST', list_chunk.id

    assert_equal 'WAVE', riff_chunk.type
    assert_equal 'INFO', list_chunk.type

    assert_equal 1411416, riff_chunk.instance_variable_get(:@size)
    assert_equal 172, list_chunk.instance_variable_get(:@size)

    # The real size should not include chunk type data
    assert_equal 1411412, riff_chunk.size
    assert_equal 168, list_chunk.size
  end

  def test_odd_size_chunk
    content = StringIO.new("IART\t\x00\x00\x00Iggy".b)
    chunk = WahWah::Riff::Chunk.new(content)

    assert_equal 9, chunk.instance_variable_get(:@size)

    # If the chunk's length is not even, add one pad byte,
    # so the real size should be even.
    assert_equal 10, chunk.size
  end

  def test_invalid_chunk
    content = StringIO.new("\x00\x00\x00\x00\x00\x00invalid".b)
    chunk = WahWah::Riff::Chunk.new(content)

    assert !chunk.valid?
  end
end
