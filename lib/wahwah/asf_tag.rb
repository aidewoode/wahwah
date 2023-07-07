# frozen_string_literal: true

module WahWah
  class AsfTag < Tag
    HEADER_OBJECT_CONTENT_SIZE = 6
    HEADER_OBJECT_GUID = "75B22630-668E-11CF-A6D9-00AA0062CE6C"
    FILE_PROPERTIES_OBJECT_GUID = "8CABDCA1-A947-11CF-8EE4-00C00C205365"
    EXTENDED_CONTENT_DESCRIPTION_OBJECT_GUID = "D2D0A440-E307-11D2-97F0-00A0C95EA850"
    STREAM_PROPERTIES_OBJECT_GUID = "B7DC0791-A9B7-11CF-8EE6-00C00C205365"
    AUDIO_MEDIA_OBJECT_GUID = "F8699E40-5B4D-11CF-A8FD-00805F5C442B"
    CONTENT_DESCRIPTION_OBJECT_GUID = "75B22633-668E-11CF-A6D9-00AA0062CE6C"

    EXTENDED_CONTENT_DESCRIPTOR_NAME_MAPPING = {
      "WM/AlbumArtist" => :albumartist,
      "WM/AlbumTitle" => :album,
      "WM/Composer" => :composer,
      "WM/Genre" => :genre,
      "WM/PartOfSet" => :disc,
      "WM/TrackNumber" => :track,
      "WM/Year" => :year,
      "WM/Lyrics" => :lyrics
    }

    private

    # ASF files are logically composed of three types of top-level objects:
    # the Header Object, the Data Object, and the Index Object(s).
    # The Header Object is mandatory and must be placed at the beginning of every ASF file.
    # Of the three top-level ASF objects, the Header Object is the only one that contains other ASF objects.
    # All Unicode strings in ASF uses UTF-16, little endian, and the Byte-Order Marker (BOM) character is not present.
    def parse
      header_object = Asf::Object.new(@file_io)
      return unless header_object.valid?

      total_header_object_size = header_object.size + Asf::Object::HEADER_SIZE

      return unless header_object.guid == HEADER_OBJECT_GUID

      # Header Object contains 6 bytes useless data, so skip it.
      @file_io.seek(HEADER_OBJECT_CONTENT_SIZE, IO::SEEK_CUR)

      until total_header_object_size <= @file_io.pos
        sub_object = Asf::Object.new(@file_io)
        parse_sub_object(sub_object)
      end
    end

    def parse_sub_object(sub_object)
      case sub_object.guid
      when FILE_PROPERTIES_OBJECT_GUID
        parse_file_properties_object(sub_object)
      when EXTENDED_CONTENT_DESCRIPTION_OBJECT_GUID
        parse_extended_content_description_object(sub_object)
      when STREAM_PROPERTIES_OBJECT_GUID
        parse_stream_properties_object(sub_object)
      when CONTENT_DESCRIPTION_OBJECT_GUID
        parse_content_description_object(sub_object)
      else
        sub_object.skip
      end
    end

    # File Properties Object structure:
    #
    # Field name                Field type  Size (bits)
    #
    # Object ID                 GUID        128
    # Object Size               QWORD       64
    # File ID                   GUID        128
    # File Size                 QWORD       64
    # Creation Date             QWORD       64
    # Data Packets Count        QWORD       64
    # Play Duration             QWORD       64
    # Send Duration             QWORD       64
    # Preroll                   QWORD       64
    # Flags                     DWORD       32
    #   Broadcast Flag                      1 (LSB)
    #   Seekable Flag                       1
    #   Reserved                            30
    # Minimum Data Packet Size  DWORD       32
    # Maximum Data Packet Size  DWORD       32
    # Maximum Bitrate DWORD                 32
    #
    # Play Duration Specifies the time needed to play the file in 100-nanosecond units.
    # The value of this field is invalid if the Broadcast Flag bit in the Flags field is set to 1.
    #
    # Preroll Specifies the amount of time to buffer data before starting to play the file, in millisecond units.
    # If this value is nonzero, the Play Duration field and all of the payload Presentation Time fields have been offset by this amount.
    def parse_file_properties_object(object)
      play_duration, preroll, flags = object.data.unpack("x40Q<x8Q<b32")
      @duration = play_duration / 10000000.0 - preroll / 1000.0 if flags[0] == "0"
    end

    # Extended Content Description Object structure:
    #
    # Field name                 Field type  Size (bits)
    #
    # Object ID                  GUID       128
    # Object Size                QWORD      64
    # Content Descriptors Count  WORD       16
    # Content Descriptors        See text   varies
    #
    #
    # The structure of each Content Descriptor:
    #
    # Field Name                  Field Type  Size (bits)
    #
    # Descriptor Name Length      WORD        16
    # Descriptor Name             WCHAR       varies
    # Descriptor Value Data Type  WORD        16
    # Descriptor Value Length     WORD        16
    # Descriptor Value            See text    varies
    #
    #
    # Specifies the type of data stored in the Descriptor Value field.
    # The types are defined in the following table.
    #
    # Value Type  Descriptor value  length
    #
    # 0x0000      Unicode string    varies
    # 0x0001      BYTE array        varies
    # 0x0002      BOOL              32
    # 0x0003      DWORD             32
    # 0x0004      QWORD             64
    # 0x0005      WORD              16
    def parse_extended_content_description_object(object)
      object_data = StringIO.new(object.data)
      descriptors_count = object_data.read(2).unpack1("v")

      descriptors_count.times do
        name_length = object_data.read(2).unpack1("v")
        name = Helper.encode_to_utf8(object_data.read(name_length), source_encoding: "UTF-16LE")
        value_type, value_length = object_data.read(4).unpack("vv")
        value = object_data.read(value_length)

        attr_value = case value_type
                     when 0
                       Helper.encode_to_utf8(value, source_encoding: "UTF-16LE")
                     when 1
                       value
                     when 2, 3
                       value.unpack1("V")
                     when 4
                       value.unpack1("Q<")
                     when 5
                       value.unpack1("v")
        end

        attr_name = EXTENDED_CONTENT_DESCRIPTOR_NAME_MAPPING[name]
        instance_variable_set("@#{attr_name}", attr_value) unless attr_name.nil?
      end
    end

    # Stream Properties Object structure:
    #
    # Field Name                    Field Type  Size (bits)
    # Object ID                     GUID        128
    # Object Size                   QWORD       64
    # Stream Type                   GUID        128
    # Error Correction Type         GUID        128
    # Time Offset                   QWORD       64
    # Type-Specific Data Length     DWORD       32
    # Error Correction Data Length  DWORD       32
    # Flags                         WORD        16
    #   Stream Number                           7 (LSB)
    #   Reserved                                8
    #   Encrypted Content Flag                  1
    # Reserved                      DWORD       32
    # Type-Specific Data            BYTE        varies
    # Error Correction Data         BYTE        varies
    #
    # Stream Type specifies the type of the stream (for example, audio, video, and so on).
    # Any streams with unrecognized Stream Type values should be ignored.
    #
    # Audio media type Object structure:
    #
    # Field name                          Field type  Size (bits)
    #
    # Codec ID / Format Tag               WORD        16
    # Number of Channels                  WORD        16
    # Samples Per Second                  DWORD       32
    # Average Number of Bytes Per Second  DWORD       32
    # Block Alignment                     WORD        16
    # Bits Per Sample                     WORD        16
    def parse_stream_properties_object(object)
      object_data = StringIO.new(object.data)
      stream_type, type_specific_data_length = object_data.read(54).unpack("a16x24V")
      stream_type_guid = Helper.byte_string_to_guid(stream_type)

      return unless stream_type_guid == AUDIO_MEDIA_OBJECT_GUID

      @sample_rate, bytes_per_second, @bit_depth = object_data.read(type_specific_data_length).unpack("x4VVx2v")
      @bitrate = (bytes_per_second * 8.0 / 1000).round
    end

    # Content Description Object structure:
    #
    # Field name          Field type  Size (bits)
    #
    # Object ID           GUID        128
    # Object Size         QWORD       64
    # Title Length        WORD        16
    # Author Length       WORD        16
    # Copyright Length    WORD        16
    # Description Length  WORD        16
    # Rating Length       WORD        16
    # Title               WCHAR       Varies
    # Author              WCHAR       Varies
    # Copyright           WCHAR       Varies
    # Description         WCHAR       Varies
    # Rating              WCHAR       Varies
    def parse_content_description_object(object)
      object_data = StringIO.new(object.data)
      title_length, author_length, copyright_length, description_length, _ = object_data.read(10).unpack("v" * 5)

      @title = Helper.encode_to_utf8(object_data.read(title_length), source_encoding: "UTF-16LE")
      @artist = Helper.encode_to_utf8(object_data.read(author_length), source_encoding: "UTF-16LE")
      object_data.seek(copyright_length, IO::SEEK_CUR)
      @comments.push(Helper.encode_to_utf8(object_data.read(description_length), source_encoding: "UTF-16LE"))
    end
  end
end
