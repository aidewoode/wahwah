# frozen_string_literal: true

module WahWah
  # http://soundfile.sapp.org/doc/WaveFormat/
  # https://en.wikipedia.org/wiki/Resource_Interchange_File_Format
  # https://docs.microsoft.com/en-us/windows/win32/multimedia/resource-interchange-file-format-services
  # http://soundfile.sapp.org/doc/WaveFormat/
  class RiffTag < Tag
    extend ID3::Delegate

    # see https://exiftool.org/TagNames/RIFF.html#Info for more info
    INFO_ID_MAPPING = {
      INAM: :title,
      TITL: :title,
      IART: :artist,
      IPRD: :album,
      ICMT: :comment,
      ICRD: :year,
      YEAR: :year,
      IGNR: :genre,
      TRCK: :track
    }

    CHANNEL_MODE_INDEX = %w(Mono Stereo)

    attr_reader :sample_rate

    def channel_mode
      CHANNEL_MODE_INDEX[@channel - 1]
    end

    private
      def parse
        top_chunk = Riff::Chunk.new(@file_io)
        @top_chunk_size = top_chunk.size

        # The top "RIFF" chunks include an additional field in the first four bytes of the data field.
        # This additional field provides the form type of the field.
        # For wav file, the value of the type field is 'WAVE'
        return unless top_chunk.id == 'RIFF' && top_chunk.type == 'WAVE'

        parse_sub_chunk
      end

      def parse_sub_chunk
        loop do
          break if end_of_top_chunk?

          sub_chunk = Riff::Chunk.new(@file_io)

          case sub_chunk.id
          when 'fmt'
            parse_fmt_chunk(sub_chunk)
          when 'data'
            parse_data_chunk(sub_chunk)
          when 'LIST'
            parse_list_chunk(sub_chunk)
          when 'id3', 'ID3'
            parse_id3_chunk(sub_chunk)
          end
        end
      end

      # The fmt chunk data structure:
      # Length             Meaning       Description
      #
      # 2(little endian)   AudioFormat   PCM = 1 (i.e. Linear quantization)
      #                                  Values other than 1 indicate some
      #                                  form of compression.
      #
      # 2(little endian)   NumChannels   Mono = 1, Stereo = 2, etc.
      #
      # 4(little endian)   SampleRate    8000, 44100, etc.
      #
      # 4(little endian)   ByteRate      == SampleRate * NumChannels * BitsPerSample/8
      #
      # 2(little endian)   BlockAlign    == NumChannels * BitsPerSample/8
      #                                  The number of bytes for one sample including
      #                                  all channels.
      #
      # 2(little endian)   BitsPerSample 8 bits = 8, 16 bits = 16, etc.
      def parse_fmt_chunk(chunk)
        _, @channel, @sample_rate, _, _, @bits_per_sample = chunk.data.unpack('vvVVvv')
        @bitrate = @sample_rate * @channel * @bits_per_sample / 1000
      end

      def parse_data_chunk(chunk)
        @duration = chunk.size * 8 / (@bitrate * 1000)
        @file_io.seek(chunk.size, IO::SEEK_CUR)
      end

      def parse_list_chunk(chunk)
        list_chunk_end_position = @file_io.pos + chunk.size

        # RIFF can be tagged with metadata in the INFO chunk.
        # And INFO chunk as a subchunk for LIST chunk.
        if chunk.type != 'INFO'
          @file_io.seek(chunk.size, IO::SEEK_CUR)
        else
          loop do
            break if list_chunk_end_position <= @file_io.pos

            info_chunk = Riff::Chunk.new(@file_io)

            unless INFO_ID_MAPPING.keys.include? info_chunk.id.to_sym
              @file_io.seek(info_chunk.size, IO::SEEK_CUR); next
            end

            update_attribute(info_chunk)
          end
        end
      end

      def parse_id3_chunk(chunk)
        @id3_tag = ID3::V2.new(StringIO.new(chunk.data))
      end

      def end_of_top_chunk?
        @top_chunk_size + Riff::Chunk::HEADER_SIZE <= @file_io.pos
      end

      def update_attribute(chunk)
        attribute_name = INFO_ID_MAPPING[chunk.id.to_sym]
        chunk_data = Helper.encode_to_utf8(chunk.data)

        case attribute_name
        when :comment
          @comments.push(chunk_data)
        else
          instance_variable_set("@#{attribute_name}", chunk_data)
        end
      end
  end
end
