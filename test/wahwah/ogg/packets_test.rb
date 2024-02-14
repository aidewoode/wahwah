# frozen_string_literal: true

require "test_helper"

class WahWah::Ogg::PacketsTest < Minitest::Test
  def setup
    @packets = WahWah::Ogg::Packets.new(File.open("test/files/vorbis_tag.ogg", "rb"))
  end

  def test_packets_enumerable
    assert_kind_of Enumerable, @packets
  end

  def test_packets_content
    first_packet, second_packet = @packets.first(2)

    assert_equal "\x01vorbis\x00\x00\x00\x00\x02D\xAC\x00\x00\x00\x00\x00\x00\x00\xEE\x02\x00\x00\x00\x00\x00\xB8\x01".b, first_packet
    assert_equal "\u0003vorbis0\u0000\u0000\u0000BS; LancerMod(SSE3) (based on aoTuV 6.03 (2018))\n\u0000\u0000\u0000\u000F\u0000\u0000\u0000ALBUM=The Idiot\u0014\u0000\u0000\u0000ALBUMARTIST=Iggy Pop\u000F\u0000\u0000\u0000ARTIST=Iggy Pop\u0011\u0000\u0000\u0000COMPOSER=Iggy Pop\t\u0000\u0000\u0000DATE=1977\u0010\u0000\u0000\u0000TITLE=China Girl\r\u0000\u0000\u0000TRACKNUMBER=5\n\u0000\u0000\u0000GENRE=Rock\f\u0000\u0000\u0000DISCNUMBER=10\u0000\u0000\u0000LYRICS=I'm feeling tragic like I'm Marlon Brando\u0001".b, second_packet
  end
end
