# frozen_string_literal: true

require 'test_helper'

class WahWah::ID3::GenreFrameBodyTest < Minitest::Test
  def test_text_value_genre
    value = WahWah::ID3::GenreFrameBody.new("\x00Rock".b, 4).value
    assert_equal 'Rock', value
  end

  def test_numeric_value_genre
    value = WahWah::ID3::GenreFrameBody.new("\x0017".b, 4).value
    assert_equal 'Rock', value
  end

  def test_numeric_value_in_parens_genre
    value = WahWah::ID3::GenreFrameBody.new("\x00(17)".b, 4).value
    assert_equal 'Rock', value
  end
end
