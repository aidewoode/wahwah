# frozen_string_literal: true

lib = File.expand_path('../lib', __FILE__)
$LOAD_PATH.unshift(lib) unless $LOAD_PATH.include?(lib)

require 'wahwah/version'

Gem::Specification.new do |spec|
  spec.name          = 'wahwah'
  spec.version       = WahWah::VERSION
  spec.authors       = ['aidewoode']
  spec.email         = ['aidewoode@gmail.com']

  spec.summary       = 'Audio metadata reader ruby gem'
  spec.description   = 'WahWah is an audio metadata reader ruby gem, it supports many popular formats including mp3(ID3 v1, v2.2, v2.3, v2.4), m4a, ogg, oga, opus, wav, flac and wma.'
  spec.homepage      = 'https://github.com/aidewoode'
  spec.license       = 'MIT'

  spec.files         = `git ls-files -z`.split("\x0").select do |f|
    f.start_with?('lib', 'pagy.gemspec', 'LICENSE')
  end

  spec.required_ruby_version = '>= 2.5.0'
  spec.require_paths = ['lib']

  spec.add_development_dependency 'bundler'
  spec.add_development_dependency 'rake', '~> 13.0'
  spec.add_development_dependency 'minitest', '~> 5.0'
  spec.add_development_dependency 'rubocop', '~> 0.80.1'
  spec.add_development_dependency 'rubocop-performance', '~> 1.5.2'
  spec.add_development_dependency 'simplecov', '~> 0.21.2'
  spec.add_development_dependency 'simplecov-lcov', '~> 0.8.0'
  spec.add_development_dependency 'memory_profiler', '~> 0.9.14'
end
