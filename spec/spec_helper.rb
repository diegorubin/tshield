# frozen_string_literal: false

require 'coveralls'
Coveralls.wear!

require 'bundler/setup'
Bundler.setup

require 'simplecov'
SimpleCov.start

require 'httparty'
require 'webmock/rspec'

require 'tshield/extensions/string_extensions'

RSpec.configure do |config|
end
