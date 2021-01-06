# frozen_string_literal: false

if ENV['COVERALLS_REPO_TOKEN']
  require 'coveralls'
  Coveralls.wear!
end

require 'bundler/setup'
Bundler.setup

require 'simplecov'
SimpleCov.start

require 'httparty'
require 'webmock/rspec'

require 'tshield/extensions/string_extensions'

RSpec.configure do |config|
end
