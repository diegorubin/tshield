# frozen_string_literal: true

# Configs of possible browsers
module Browsers
  CAPS ||= {
    'chromeOptions' => {
      'args' => ['--window-size=1600,1300', '--test-type', '--no-sandbox', '--incognito'],
      'excludeSwitches' => ['--ignore-certificate-errors']
    }
  }

  def self.register_chrome(app)
    Capybara::Selenium::Driver.new(
      app,
      browser: :chrome,
      http_client: client,
      desired_capabilities: Selenium::WebDriver::Remote::Capabilities.chrome(CAPS)
    )
  end

  def self.register_chromeheadless(app)
    CAPS['chromeOptions']['args'].push 'headless'
    CAPS['chromeOptions']['args'].push 'disable-gpu'
    CAPS['chromeOptions']['args'].push 'no-sandbox'
    Capybara::Selenium::Driver.new(
      app,
      browser: :chrome,
      http_client: client,
      desired_capabilities: Selenium::WebDriver::Remote::Capabilities.chrome(CAPS)
    )
  end

  def self.client
    client = Selenium::WebDriver::Remote::Http::Default.new
    client.open_timeout = 120 # seconds
    client.read_timeout = 240 # seconds
    client
  end
end
