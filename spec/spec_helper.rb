# frozen_string_literal: false

require 'bundler/setup'
Bundler.setup

require 'simplecov'
SimpleCov.start

require 'httparty'
require 'webmock/rspec'

RSpec.configure do |config|
  config.before(:each) do
    allow(File).to receive(:join).and_return(
      'spec/tshield/fixtures/config/tshield.yml'
    )
  end
end
