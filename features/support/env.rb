# frozen_string_literal: true

require 'httparty'
require 'rspec'
require 'grpc'

require_relative './helpers/requests_helpers.rb'
require_relative './helpers/tshield_helpers.rb'
require_relative './helpers/users_helpers.rb'
require_relative './helpers/grpc_helpers.rb'

# for grpc features
lib_dir = File.join(Dir.pwd, 'component_tests', 'proto')
$LOAD_PATH.unshift(lib_dir) unless $LOAD_PATH.include?(lib_dir)
puts lib_dir
require 'helloworld_services_pb'

at_exit do
  system('fuser -k 4567/tcp')
end
