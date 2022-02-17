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
      @data = get_data if @file_io.is_a?(StringIO)
    end

    def data
      if @file_io.closed? && @file_io.is_a?(File)
        @file_io = File.open(@file_io.path)
        @data = get_data
        @file_io.close
      end

      @data ||= get_data
    end

    def skip
      @file_io.seek(@position)
      @file_io.seek(size, IO::SEEK_CUR)
    end

    private

    def get_data
      @file_io.seek(@position)
      @file_io.read(size)
    end
  end
end
