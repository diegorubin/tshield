# frozen_string_literal: true

Given('a valid gRPC method {string} defined in {string}') do |method_name, service|
  service = Kernel.const_get("#{service}::Stub")
  @method = method_name
  @service_instance = service.new('localhost:5678', :this_channel_is_insecure)
end

When('this method called throught tshield with request {string}') do |request_type|
  request_instance = Kernel.const_get(request_type.to_s).new(GrpcHelpers.example_request)
  @service_instance.send(@method.to_sym, request_instance)
end

When('this method called throught tshield with request {string} expecting an connection error') do |request_type|
  puts Kernel.const_get(request_type.to_s)
  request_instance = Kernel.const_get(request_type.to_s).new(GrpcHelpers.example_request)

  expect {
    require @service_instance.send(@method.to_sym, request_instance)
  }.to raise_error(/14:failed to connect to all addresses./)
end

Then('grpc response should be saved in {string}') do |directory|
  directory = File.join './component_tests', directory
  request_file = JSON.parse(File.read(File.join(directory, 'original_request')))
  response_file = JSON.parse(File.read(File.join(directory, 'response')))
  response_class_file = File.read(File.join(directory, 'response_class')).strip

  expect(response_file).to eql(GrpcHelpers.example_response)
  expect(response_class_file).to eql('Helloworld::HelloReply')
  expect(request_file).to eql(GrpcHelpers.example_request)
end

Then('grpc original_request file should be saved in {string}') do |directory|
  directory = File.join './component_tests', directory
  request_file = JSON.parse(File.read(File.join(directory, 'original_request')))

  expect(request_file).to eql(GrpcHelpers.example_request)
end

Then('grpc response file should not be saved in {string}') do |directory|
  directory = File.join './component_tests', directory
  expect {File.read(File.join(directory, 'response'))}.to raise_error(/No such file or directory/)
  expect {File.read(File.join(directory, 'response_class'))}.to raise_error(/No such file or directory/)
end

