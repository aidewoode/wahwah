# frozen_string_literal: true

require 'simplecov'

if ENV['CI'] == 'true'
  require 'codecov'
  SimpleCov.formatter = SimpleCov::Formatter::Codecov
end

SimpleCov.start do
  add_filter '/test/'
end

$LOAD_PATH.unshift File.expand_path('../../lib', __FILE__)

require 'wahwah'
require 'minitest/autorun'

module TestHelpers
  def binary_data(file_path)
    File.read(file_path).force_encoding('BINARY').strip
  end

  def file_io_closed?(tag)
    tag.instance_variable_get(:@file_io).closed?
  end
end

Minitest::Test.send(:include, TestHelpers)
