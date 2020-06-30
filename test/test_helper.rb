# frozen_string_literal: true

$LOAD_PATH.unshift File.expand_path('../../lib', __FILE__)

require 'wahwah'
require 'minitest/autorun'
require 'simplecov'

SimpleCov.start

if ENV['CI'] == 'true'
  require 'codecov'
  SimpleCov.formatter = SimpleCov::Formatter::Codecov
end

module TestHelpers
  def binary_data(file_path)
    File.read(file_path).force_encoding('BINARY').strip
  end
end

Minitest::Test.send(:include, TestHelpers)
