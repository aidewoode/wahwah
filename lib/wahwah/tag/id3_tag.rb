# frozen_string_literal: true

module WahWah
  class Id3Tag < Tag
    ID3V1_TAG_SIZE = 128
    ID3V1_TAG_ID = 'TAG'
    ID3V1_DEFAULT_ENCODING = 'iso-8859-1'
    ID3V1_GENRES = [
      # Standard Genres
      'Blues', 'Classic Rock', 'Country', 'Dance', 'Disco', 'Funk', 'Grunge',
      'Hip-Hop', 'Jazz', 'Metal', 'New Age', 'Oldies', 'Other', 'Pop',
      'R&B', 'Rap', 'Reggae', 'Rock', 'Techno', 'Industrial', 'Alternative',
      'Ska', 'Death Metal', 'Pranks', 'Soundtrack', 'Euro-Techno', 'Ambient', 'Trip-Hop',
      'Vocal', 'Jazz+Funk', 'Fusion', 'Trance', 'Classical', 'Instrumental', 'Acid',
      'House', 'Game', 'Sound Clip', 'Gospel', 'Noise', 'AlternRock', 'Bass',
      'Soul', 'Punk', 'Space', 'Meditative', 'Instrumental Pop', 'Instrumental Rock', 'Ethnic',
      'Gothic', 'Darkwave', 'Techno-Industrial', 'Electronic', 'Pop-Folk', 'Eurodance', 'Dream',
      'Southern Rock', 'Comedy', 'Cult', 'Gangsta', 'Top 40', 'Christian Rap', 'Pop/Funk',
      'Jungle', 'Native American', 'Cabaret', 'New Wave', 'Psychadelic', 'Rave', 'Showtunes',
      'Trailer', 'Lo-Fi', 'Tribal', 'Acid Punk', 'Acid Jazz', 'Polka', 'Retro',
      'Musical', 'Rock & Roll', 'Hard Rock',

      # Winamp Extended Genres
      'Folk', 'Folk-Rock', 'National Folk', 'Swing', 'Fast Fusion', 'Bebob', 'Latin',
      'Revival', 'Celtic', 'Bluegrass', 'Avantgarde', 'Gothic Rock', 'Progressive Rock', 'Psychedelic Rock',
      'Symphonic Rock', 'Slow Rock', 'Big Band', 'Chorus', 'Easy Listening', 'Acoustic', 'Humour',
      'Speech', 'Chanson', 'Opera', 'Chamber Music', 'Sonata', 'Symphony', 'Booty Bass',
      'Primus', 'Porn Groove', 'Satire', 'Slow Jam', 'Club', 'Tango', 'Samba',
      'Folklore', 'Ballad', 'Power Ballad', 'Rhythmic Soul', 'Freestyle', 'Duet', 'Punk Rock',
      'Drum Solo', 'A capella', 'Euro-House', 'Dance Hall', 'Goa', 'Drum & Bass', 'Club-House',
      'Hardcore Techno', 'Terror', 'Indie', 'BritPop', 'Negerpunk', 'Polsk Punk', 'Beat',
      'Christian Gangsta Rap', 'Heavy Metal', 'Black Metal', 'Contemporary Christian', 'Christian Rock',

      # Added on WinAmp 1.91
      'Merengue', 'Salsa', 'Thrash Metal', 'Anime', 'Jpop', 'Synthpop',

      # Added on WinAmp 5.6
      'Abstract', 'Art Rock', 'Baroque', 'Bhangra', 'Big Beat', 'Breakbeat', 'Chillout',
      'Downtempo', 'Dub', 'EBM', 'Eclectic', 'Electro', 'Electroclash', 'Emo',
      'Experimental', 'Garage', 'Illbient', 'Industro-Goth', 'Jam Band', 'Krautrock', 'Leftfield',
      'Lounge', 'Math Rock', 'New Romantic', 'Nu-Breakz', 'Post-Punk', 'Post-Rock', 'Psytrance',
      'Shoegaze', 'Space Rock', 'Trop Rock', 'World Music', 'Neoclassical', 'Audiobook', 'Audio Theatre',
      'Neue Deutsche Welle', 'Podcast', 'Indie Rock', 'G-Funk', 'Dubstep', 'Garage Rock', 'Psybient'
    ]

    def parse(file)
      @file = file

      if is_id3v1?
        parse_id3v1
      else
        parse_id3v2
      end
    end

    private

      def is_id3v1?
        @file.seek(-ID3V1_TAG_SIZE, IO::SEEK_END)
        @file.read(3) == ID3V1_TAG_ID
      end

      def parse_id3v1
        # For ID3v1 info, see here https://en.wikipedia.org/wiki/ID3#ID3v1

        @file.seek(-(ID3V1_TAG_SIZE - ID3V1_TAG_ID.size), IO::SEEK_END)
        @title = encode_to_utf8(ID3V1_DEFAULT_ENCODING, @file.read(30).strip)
        @artist = encode_to_utf8(ID3V1_DEFAULT_ENCODING, @file.read(30).strip)
        @album = encode_to_utf8(ID3V1_DEFAULT_ENCODING, @file.read(30).strip)
        @year = encode_to_utf8(ID3V1_DEFAULT_ENCODING, @file.read(4).strip)

        comment = @file.read(30)

        if comment.getbyte(-2) == 0
          @track = comment.getbyte(-1).to_i
          @comment = encode_to_utf8(ID3V1_DEFAULT_ENCODING, comment.byteslice(0..-3).strip)
        end

        @genre = ID3V1_GENRES[@file.getbyte] || ''
      end

      def parse_id3v2
      end
  end
end
