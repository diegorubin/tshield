# frozen_string_literal: true

Before do |scenario|
  puts "==> Scenario '#{scenario.name}' started"
  stop_session
  Capybara.current_session.current_window.resize_to('1366', '768')
end

After do |scenario|
  stop_session
  puts "==> Scenario '#{scenario.name}' finished"
end
