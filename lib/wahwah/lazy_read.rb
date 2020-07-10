# frozen_string_literal: true

module WahWah
  module LazyRead
    def self.prepended(base)
      base.class_eval do
        attr_reader :size
      end
    end

    def initialize(file_io, *arg)
      @file_io = file_io
      super(*arg)
      @position = @file_io.pos
    end

    def data
      @file_io.seek(@position)
      @file_io.read(size)
    end

    def skip
      @file_io.seek(size, IO::SEEK_CUR)
    end
  end
end
