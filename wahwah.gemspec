# frozen_string_literal: true

lib = File.expand_path('../lib', __FILE__)
$LOAD_PATH.unshift(lib) unless $LOAD_PATH.include?(lib)

require 'wahwah/version'

Gem::Specification.new do |spec|
  spec.name          = 'wahwah'
  spec.version       = WahWah::VERSION
  spec.authors       = ['aidewoode']
  spec.email         = ['aidewoode@gmail.com']

  spec.summary       = 'A library for reading meta data from audio'
  spec.description   = 'A library written in pure ruby for reading meta data from audio, and support several common audio formats.'
  spec.homepage      = 'https://github.com/aidewoode'
  spec.license       = 'MIT'

  spec.files         = `git ls-files -z`.split("\x0").reject do |f|
    f.match(%r{^(test|spec|features)/})
  end

  spec.required_ruby_version = '>= 2.4.0'
  spec.require_paths = ['lib']

  spec.add_development_dependency 'bundler', '~> 1.14.0'
  spec.add_development_dependency 'rake', '~> 13.0'
  spec.add_development_dependency 'minitest', '~> 5.0'
  spec.add_development_dependency 'rubocop', '~> 0.80.1'
end
