# WahWah

[![Build Status](https://travis-ci.org/aidewoode/wahwah.svg?branch=master)](https://travis-ci.org/aidewoode/wahwah)
[![codecov](https://codecov.io/gh/aidewoode/wahwah/branch/master/graph/badge.svg)](https://codecov.io/gh/aidewoode/wahwah)

WahWah is an audio metadata reader ruby gem, it supports many popular formats including mp3(ID3 v1, v2.2, v2.3, v2.4), m4a, ogg, oga, opus, wav, flac and wma.

WahWah is written in pure ruby, and without any dependencies.

## Installation

Add this line to your application's Gemfile:

```ruby
gem 'wahwah'
```

And then execute:

    $ bundle

Or install it yourself as:

    $ gem install wahwah


## Compatibility

WahWah support ruby 2.5+

## Usage

WahWah is so easy to use.

```ruby
# Get metadata from an audio file

tag = WahWah.open('/files/example.wav')

tag.title       # => 'song title' 
tag.artist      # => 'artist name'
tag.album       # => 'album name'
tag.albumartist # => 'albumartist name'
tag.composer    # => 'composer name'
tag.comments    # => ['comment', 'another comment']
tag.track       # => 1
tag.track_total # => 10
tag.genre       # => 'Rock'
tag.year        # => '1984'
tag.disc        # => 1
tag.disc_total  # => 2
tag.duration    # => 256 (in seconds) 
tag.bitrate     # => 192 (in kbps) 
tag.sample_rate # => 44100 (in Hz)
tag.bit_depth   # => 16 (in bits, only for PCM formats)
tag.file_size   # => 976700 (in bytes)
tag.images      # => [{ :type => :cover_front, :mime_type => 'image/jpeg', :data => 'image data binary string' }]


# Get all support formats

WahWah.support_formats # => ['mp3', 'ogg', 'oga', 'opus', 'wav', 'flac', 'wma', 'm4a']
```
