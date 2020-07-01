# frozen_string_literal: true

$LOAD_PATH.unshift File.expand_path('../../lib', __FILE__)

require 'simplecov'

SimpleCov.start do
  add_filter '/test/'
end

if ENV['CI'] == 'true'
  require 'codecov'
  SimpleCov.formatter = SimpleCov::Formatter::Codecov
end

module TestHelpers
  def binary_data(file_path)
    File.read(file_path).force_encoding('BINARY').strip
  end
end

require 'wahwah'
require 'minitest/autorun'

Minitest::Test.send(:include, TestHelpers)
