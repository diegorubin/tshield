# frozen_string_literal: true

And('tshield has started with {string} config file') do |config_name|
  system('fuser -k 4567/tcp')
  system("cd component_tests && ../bin/tshield -c #{config_name} & ")
  sleep(3)
end
