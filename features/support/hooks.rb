# frozen_string_literal: true

require 'fileutils'

Before do
  # clear requests directory
  FileUtils.rm_rf('./component_tests/requests')

  # stop sessions
  TShieldHelpers.stop_session
end

After('@windows') do
  # restoring default tshield configuration
  system('fuser -k 4567/tcp')
  system("cd component_tests && ../bin/tshield -c config.yml & ")
  sleep(3)
end
