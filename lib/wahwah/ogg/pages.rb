# frozen_string_literal: true

module WahWah
  module Ogg
    class Pages
      include Enumerable

      def initialize(file_io)
        @file_io = file_io
      end

      def each
        @file_io.rewind

        until @file_io.eof?
          page = Ogg::Page.new(@file_io)
          break unless page.valid?

          yield page
        end
      end
    end
  end
end
