# frozen_string_literal: true

module WahWah
  module Mp3
    # mpeg frame header structure:
    #
    # Position   Length    Meaning
    # 0	         11	       Frame sync to find the header (all bits are always set)
    #
    # 11	       2         Audio version ID
    #                      00 - MPEG Version 2.5 (unofficial extension of MPEG 2)
    #                      01 - reserved
    #                      10 - MPEG Version 2 (ISO/IEC 13818-3)
    #                      11 - MPEG Version 1 (ISO/IEC 11172-3)
    #
    # 13	       2         Layer index
    #                      00 - reserved
    #                      01 - Layer III
    #                      10 - Layer II
    #                      11 - Layer I
    #
    # 15	       1         Protection bit
    #
    # 16	       4         Bitrate index, see FRAME_BITRATE_INDEX constant
    #
    # 20	       2         Sampling rate index, see SAMPLE_RATES_INDEX constant
    #
    # 22	       1         Padding bit
    #
    # 23	       1         Private bit
    #
    # 24	       2         Channel mode
    #                      00 - Stereo
    #                      01 - Joint Stereo (Stereo)
    #                      10 - Dual channel (Two mono channels)
    #                      11 - Single channel (Mono)
    #
    # 26	       2         Mode extension (Only used in Joint Stereo)
    #
    # 28	       1         Copyright bit (only informative)
    #
    # 29	       1         Original bit (only informative)
    #
    # 30	       2         Emphasis
    class MpegFrameHeader
      HEADER_SIZE = 4

      FRAME_BITRATE_INDEX = {
        'MPEG1 layer1' => [0, 32, 64, 96, 128, 160, 192, 224, 256, 288, 320, 352, 384, 416, 448, 0],
        'MPEG1 layer2' => [0, 32, 48, 56, 64, 80, 96, 112, 128, 160, 192, 224, 256, 320, 384, 0],
        'MPEG1 layer3' => [0, 32, 40, 48, 56, 64, 80, 96, 112, 128, 160, 192, 224, 256, 320, 0],

        'MPEG2 layer1' => [0, 32, 48, 56, 64, 80, 96, 112, 128, 144, 160, 176, 192, 224, 256, 0],
        'MPEG2 layer2' => [0, 8, 16, 24, 32, 40, 48, 56, 64, 80, 96, 112, 128, 144, 160, 0],
        'MPEG2 layer3' => [0, 8, 16, 24, 32, 40, 48, 56, 64, 80, 96, 112, 128, 144, 160, 0],

        'MPEG2.5 layer1' => [0, 32, 48, 56, 64, 80, 96, 112, 128, 144, 160, 176, 192, 224, 256, 0],
        'MPEG2.5 layer2' => [0, 8, 16, 24, 32, 40, 48, 56, 64, 80, 96, 112, 128, 144, 160, 0],
        'MPEG2.5 layer3' => [0, 8, 16, 24, 32, 40, 48, 56, 64, 80, 96, 112, 128, 144, 160, 0]
      }

      VERSIONS_INDEX = ['MPEG2.5', nil, 'MPEG2', 'MPEG1']
      LAYER_INDEX = [nil, 'layer3', 'layer2', 'layer1']
      CHANNEL_MODE_INDEX = ['Stereo', 'Joint Stereo', 'Dual Channel', 'Single Channel']

      SAMPLE_RATES_INDEX = {
        'MPEG1' => [44100, 48000, 32000],
        'MPEG2' => [22050, 24000, 16000],
        'MPEG2.5' => [11025, 12000, 8000]
      }

      SAMPLES_PER_FRAME_INDEX = {
        'MPEG1 layer1' => 384,
        'MPEG1 layer2' => 1152,
        'MPEG1 layer3' => 1152,

        'MPEG2 layer1' => 384,
        'MPEG2 layer2' => 1152,
        'MPEG2 layer3' => 576,

        'MPEG2.5 layer1' => 384,
        'MPEG2.5 layer2' => 1152,
        'MPEG2.5 layer3' => 576
      }

      attr_reader :position

      def initialize(file_io, offset = 0)
        parse(file_io, offset)
      end

      def version
        @version ||= VERSIONS_INDEX[@header[11..12].to_i(2)]
      end

      def layer
        @layer ||= LAYER_INDEX[@header[13..14].to_i(2)]
      end

      def kind
        "#{version} #{layer}"
      end

      def frame_bitrate
        @frame_bitrate ||= FRAME_BITRATE_INDEX[kind]&.fetch(@header[16..19].to_i(2))
      end

      def channel_mode
        @channel_mode ||= CHANNEL_MODE_INDEX[@header[24..25].to_i(2)]
      end

      def sample_rates
        @sample_rates ||= SAMPLE_RATES_INDEX[version]&.fetch(@header[20..21].to_i(2))
      end

      def samples_per_frame
        SAMPLES_PER_FRAME_INDEX[kind]
      end

      private
        def parse(file_io, offset)
          file_io.rewind

          # mpeg frame header start with '11111111111' sync bits,
          # So look through file until find it.
          loop do
            header = file_io.pread(HEADER_SIZE, offset)
            sync_bits = header.unpack('B11').first

            if sync_bits == "#{'1' * 11}".b
              @header = header.unpack('B*').first
              @position = offset

              break
            end

            offset += 1
          end
        end
    end
  end
end
