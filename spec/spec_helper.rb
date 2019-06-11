# frozen_string_literal: true

require 'bundler/setup'
Bundler.setup

require 'simplecov'
SimpleCov.start

require 'httparty'

require 'webmock/rspec'

RSpec.configure do |config|
  config.before(:each) do
    allow(File).to receive(:join) do
      'spec/tshield/fixtures/config/tshield.yml'
    end
  end
end
