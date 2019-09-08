# frozen_string_literal: false

require 'capybara'
require 'capybara/cucumber'
require 'httparty'
require 'selenium-webdriver'
require 'rspec'
require 'site_prism'

require_relative 'helpers/browsers'
require_relative 'helpers/tshield'

Capybara.default_driver = :selenium

BROWSER = ENV['BROWSER'] || 'chrome'
ENVIRONMENT = ENV['ENVIRONMENT'] || 'local'
CAPYBARA_TIMEOUT = ENV['CAPYBARA_TIMEOUT'] || 5

puts "# environment: #{ENVIRONMENT}"
puts "# browser:     #{BROWSER}"
puts "# timeout: #{CAPYBARA_TIMEOUT}"

$env = YAML.load_file('./config/environments.yml')[ENVIRONMENT]

## register driver according with environment and browser chosen
Capybara.register_driver :selenium do |app|
  Browsers.send("register_#{BROWSER}", app)
end

Capybara.default_max_wait_time = CAPYBARA_TIMEOUT.to_i

module CustomWorld
  include Helpers::TShield
end

World(CustomWorld)
