### 1.5.0

- New features
  - Support for retrieving lyrics from metadata.

### 1.4.0

- Enhancements
  - Support get bit depth for ALAC encoded format(#29)

- Breaking changes
  - Drop support for Ruby 2.6

### 1.3.0

- Enhancements
  - Support read meta atom from moov atom(#26).

### 1.2.0

- Enhancements
  - Use standard ruby style guide for code.

- Breaking change
  - Return the duration as a float instead of as an integer(#24).
  - Drop support for ruby 2.5.

### 1.1.1

- Enhancements
  - Allow file IO to be closed automatically.

### 1.1.0

- New features
  - Add bit_depth attribute for PCM formats audio.

- Bug fixes
  - Fix can not parse lowercase field name on vorbis comment.

- Enhancements
  - Lazy load images attribute to reduce memory allocate.
