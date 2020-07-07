# frozen_string_literal: true

# Grpc Helpers
module GrpcHelpers
  def self.example_response
    { 'message' => 'Client send component tests' }
  end

  def self.example_request
    { 'name' => 'component tests' }
  end
end
