# frozen_string_literal: true

require "test_helper"

class WahWah::ID3::FrameBodyTest < Minitest::Test
  class SubFrameBody < WahWah::ID3::FrameBody; end

  class SubFrameBodyWithParse < WahWah::ID3::FrameBody
    def parse
    end
  end

  def test_sub_class_not_implemented_parse_method
    assert_raises(WahWah::WahWahNotImplementedError) do
      SubFrameBody.new("content", 3)
    end
  end

  def test_have_value_method
    frame_body = SubFrameBodyWithParse.new("content", 3)
    assert_respond_to frame_body, :value
  end
end
