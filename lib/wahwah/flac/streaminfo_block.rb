# frozen_string_literal: true

module WahWah
  module Flac
    module StreaminfoBlock
      STREAMINFO_BLOCK_SIZE = 34

      # STREAMINFO block data structure:
      #
      # Length(bit)  Meaning
      #
      # 16           The minimum block size (in samples) used in the stream.
      #
      # 16           The maximum block size (in samples) used in the stream.
      #              (Minimum blocksize == maximum blocksize) implies a fixed-blocksize stream.
      #
      # 24           The minimum frame size (in bytes) used in the stream.
      #              May be 0 to imply the value is not known.
      #
      # 24          The maximum frame size (in bytes) used in the stream.
      #              May be 0 to imply the value is not known.
      #
      # 20           Sample rate in Hz. Though 20 bits are available,
      #              the maximum sample rate is limited by the structure of frame headers to 655350Hz.
      #              Also, a value of 0 is invalid.
      #
      # 3            (number of channels)-1. FLAC supports from 1 to 8 channels
      #
      # 5            (bits per sample)-1. FLAC supports from 4 to 32 bits per sample.
      #              Currently the reference encoder and decoders only support up to 24 bits per sample.
      #
      # 36           Total samples in stream. 'Samples' means inter-channel sample,
      #              i.e. one second of 44.1Khz audio will have 44100 samples regardless of the number of channels.
      #              A value of zero here means the number of total samples is unknown.
      #
      # 128          MD5 signature of the unencoded audio data.
      def parse_streaminfo_block(block_data)
        return unless block_data.size == STREAMINFO_BLOCK_SIZE

        info_bits = block_data.unpack1("x10B64")

        @sample_rate = info_bits[0..19].to_i(2)
        @bit_depth = info_bits[23..27].to_i(2) + 1
        total_samples = info_bits[28..].to_i(2)

        @duration = total_samples.to_f / @sample_rate if @sample_rate > 0
        @bitrate = @sample_rate * @bit_depth / 1000
      end
    end
  end
end
