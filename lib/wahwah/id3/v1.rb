# frozen_string_literal: true

module WahWah
  module ID3
    class V1 < Tag
      TAG_SIZE = 128
      TAG_ID = 'TAG'
      DEFAULT_ENCODING = 'iso-8859-1'
      GENRES = [
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

      # For ID3v1 info, see here https://en.wikipedia.org/wiki/ID3#ID3v1
      #
      # header    3         "TAG"
      # title     30        30 characters of the title
      # artist    30        30 characters of the artist name
      # album     30        30 characters of the album name
      # year      4         A four-digit year
      # comment   28 or 30  The comment.
      # zero-byte 1         If a track number is stored, this byte contains a binary 0.
      # track     1         The number of the track on the album, or 0. Invalid, if previous byte is not a binary 0.
      # genre     1         Index in a list of genres, or 255
      def size
        TAG_SIZE
      end

      private
        def parse
          @file_io.seek(-(TAG_SIZE - TAG_ID.size), IO::SEEK_END)
          @title = Helper.encode_to_utf8(DEFAULT_ENCODING, @file_io.read(30))
          @artist = Helper.encode_to_utf8(DEFAULT_ENCODING, @file_io.read(30))
          @album = Helper.encode_to_utf8(DEFAULT_ENCODING, @file_io.read(30))
          @year = Helper.encode_to_utf8(DEFAULT_ENCODING, @file_io.read(4))

          comment = @file_io.read(30)

          if comment.getbyte(-2) == 0
            @track = comment.getbyte(-1).to_i
            comment = Helper.encode_to_utf8(DEFAULT_ENCODING, comment.byteslice(0..-3))
          end

          @comments = [comment]
          @genre = GENRES[@file_io.getbyte] || ''
        end
    end
  end
end
