# frozen_string_literal: true

module WahWah
  class RiffTag < Tag
    extend TagDelegate

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

    CHANNEL_MODE_INDEX = %w[Mono Stereo]

    tag_delegate :@id3_tag,
      :title,
      :artist,
      :album,
      :albumartist,
      :composer,
      :comments,
      :track,
      :track_total,
      :genre,
      :year,
      :disc,
      :disc_total,
      :images

    def channel_mode
      CHANNEL_MODE_INDEX[@channel - 1]
    end

    private

    def parse
      top_chunk = Riff::Chunk.new(@file_io)
      return unless top_chunk.valid?

      total_chunk_size = top_chunk.size + Riff::Chunk::HEADER_SIZE

      # The top "RIFF" chunks include an additional field in the first four bytes of the data field.
      # This additional field provides the form type of the field.
      # For wav file, the value of the type field is 'WAVE'
      return unless top_chunk.id == "RIFF" && top_chunk.type == "WAVE"

      until total_chunk_size <= @file_io.pos || @file_io.eof?
        sub_chunk = Riff::Chunk.new(@file_io)
        parse_sub_chunk(sub_chunk)
      end
    end

    def parse_sub_chunk(sub_chunk)
      return unless sub_chunk.valid?

      case sub_chunk.id
      when "fmt"
        parse_fmt_chunk(sub_chunk)
      when "data"
        parse_data_chunk(sub_chunk)
      when "LIST"
        parse_list_chunk(sub_chunk)
      when "id3", "ID3"
        parse_id3_chunk(sub_chunk)
      else
        sub_chunk.skip
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
      _, @channel, @sample_rate, _, _, @bit_depth = chunk.data.unpack("vvVVvv")
      @bitrate = @sample_rate * @channel * @bit_depth / 1000

      # There is a rare situation where the data chunk is not included in the top RIFF chunk.
      # In this case, the duration can not be got from the data chunk, some player even cannot play the file.
      # So try to estimate the duration from the file size and bitrate.
      # This may be inaccurate, but at least can get approximate duration.
      @duration = (@file_size * 8) / (@bitrate * 1000).to_f if @duration.nil?
    end

    def parse_data_chunk(chunk)
      @duration = chunk.size * 8 / (@bitrate * 1000).to_f
      chunk.skip
    end

    def parse_list_chunk(chunk)
      list_chunk_end_position = @file_io.pos + chunk.size

      # RIFF can be tagged with metadata in the INFO chunk.
      # And INFO chunk as a subchunk for LIST chunk.
      if chunk.type != "INFO"
        chunk.skip
        return
      end

      until list_chunk_end_position <= @file_io.pos
        info_chunk = Riff::Chunk.new(@file_io)

        unless INFO_ID_MAPPING.key? info_chunk.id.to_sym
          info_chunk.skip
          next
        end

        update_attribute(info_chunk)
      end
    end

    def parse_id3_chunk(chunk)
      @id3_tag = ID3::V2.new(StringIO.new(chunk.data))
    end

    def update_attribute(chunk)
      attr_name = INFO_ID_MAPPING[chunk.id.to_sym]
      chunk_data = Helper.encode_to_utf8(chunk.data)

      case attr_name
      when :comment
        @comments.push(chunk_data)
      else
        instance_variable_set("@#{attr_name}", chunk_data)
      end
    end
  end
end
