# frozen_string_literal: true

require "test_helper"

class WahWah::Ogg::PagesTest < Minitest::Test
  def setup
    @pages = WahWah::Ogg::Pages.new(File.open("test/files/vorbis_tag.ogg", "rb"))
  end

  def test_pages_enumerable
    assert_kind_of Enumerable, @pages
  end

  def test_each_page
    @pages.each do |page|
      assert_instance_of WahWah::Ogg::Page, page
    end
  end
end
