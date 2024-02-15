# WahWah

[![CI](https://github.com/aidewoode/wahwah/actions/workflows/ci.yml/badge.svg)](https://github.com/aidewoode/wahwah/actions/workflows/ci.yml)
[![Coverage Status](https://coveralls.io/repos/github/aidewoode/wahwah/badge.svg?branch=master)](https://coveralls.io/github/aidewoode/wahwah?branch=master)
[![Ruby Style Guide](https://img.shields.io/badge/code_style-standard-brightgreen.svg)](https://github.com/testdouble/standard)

WahWah is an audio metadata reader Ruby gem, it supports many popular formats including mp3(ID3 v1, v2.2, v2.3, v2.4), m4a, ogg, oga, opus, wav, flac and wma.

WahWah is written in pure Ruby, and without any dependencies.

## Installation

Add this line to your application's Gemfile:

```ruby
gem "wahwah"
```

And then execute:

    $ bundle

Or install it yourself as:

    $ gem install wahwah


## Compatibility

WahWah support Ruby 2.7+

## Usage

WahWah is so easy to use.

```ruby
require "wahwah"

# Get metadata from an audio file

tag = WahWah.open("/files/example.wav")

tag.title       # => "song title"
tag.artist      # => "artist name"
tag.album       # => "album name"
tag.albumartist # => "albumartist name"
tag.composer    # => "composer name"
tag.comments    # => ["comment", "another comment"]
tag.track       # => 1
tag.track_total # => 10
tag.genre       # => "Rock"
tag.year        # => "1984"
tag.disc        # => 1
tag.disc_total  # => 2
tag.lyrics      # => "song lyrics"
tag.duration    # => 256.1 (in seconds)
tag.bitrate     # => 192 (in kbps)
tag.sample_rate # => 44100 (in Hz)
tag.bit_depth   # => 16 (in bits, only for PCM formats)
tag.file_size   # => 976700 (in bytes)
tag.images      # => [{ :type => :cover_front, :mime_type => 'image/jpeg', :data => 'image data binary string' }]


# Get all support formats

WahWah.support_formats # => ["mp3", "ogg", "oga", "opus", "wav", "flac", "wma", "m4a"]
```

### Streaming from an IO

`WahWah.open` can also use already opened files and file-like IOs. When initialized this way, some tags will be lazily loaded, and the file will need to stay open while accessing a given tag for the first time. Calling `load_fully` will load all the tags eagerly.

```ruby
require "wahwah"

File.open("/files/example.ogg") do |file|
  tag = WahWah.open(file)
  tag.duration # => 656.0 (in seconds)
end


# Or, this can be used to stream downloads! Lazy-loading is helpful here
# because some formats require you to read to the end (and thus download the
# whole file) to get certain data – e.g., ID3v1 has its metadata at the end,
# and Ogg requires reading the whole file to calculate bitrate or duration.

require "down"

stream = Down.open("https://github.com/aidewoode/wahwah/raw/master/test/files/vorbis_tag.ogg")
tag = WahWah.open(stream)
tag.load_fully
stream.close

# Accessible after the stream was closed thanks to `load_fully`.
tag.duration # => 8.0 (in seconds)
```
