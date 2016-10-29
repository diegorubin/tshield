require 'bundler/setup'
Bundler.setup

require 'simplecov'
SimpleCov.start

require 'httparty'
require 'tshield'

require 'webmock/rspec'

RSpec.configure do |config|

  config.before(:each) do 
  end

end

