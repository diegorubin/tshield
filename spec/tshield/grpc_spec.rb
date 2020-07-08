# frozen_string_literal: true

require 'spec_helper'

require 'tshield/grpc'

describe TShield::Grpc do
  context 'on load services' do
    before :each do
      lib_dir = File.join(__dir__, 'fixtures/proto')
      $LOAD_PATH.unshift(lib_dir) unless $LOAD_PATH.include?(lib_dir)

      @services = {
        'test_services_pb' => { 'module' => 'TestServices', 'hostname' => '0.0.0.0:5678' }
      }
    end

    it 'should implement a service from options' do
      implementation = TShield::Grpc.load_services(@services).first
      instance = implementation.new
      expect(instance.respond_to?(:service_method)).to be_truthy
    end
  end
end
