# frozen_string_literal: true

require "test_helper"

class WahWah::Flac::StreaminfoBlockTest < Minitest::Test
  class Block
    include WahWah::Flac::StreaminfoBlock

    def initialize(block_data)
      parse_streaminfo_block(block_data)
    end
  end

  def test_parse
    block = Block.new("\x10\x00\x10\x00\x00\x00\x0E\x00\x00\x10\n\xC4B\xF0\x00\x05b d\xA9\xFD\x7Fl\xB0\xE1\xC9Z\xFE\xCD\xF3\xA3iqO".b)

    assert_equal 8.0, block.instance_variable_get(:@duration)
    assert_equal 705, block.instance_variable_get(:@bitrate)
    assert_equal 44100, block.instance_variable_get(:@sample_rate)
    assert_equal 16, block.instance_variable_get(:@bit_depth)
  end
end
