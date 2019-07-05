# frozen_string_literal: true

require 'test_helper'

class WahWahTest < Minitest::Test
  def test_not_support_format
    assert_raises(WahWah::WahWhArgumentError) do
      WahWah.open('test.example')
    end
  end
end
