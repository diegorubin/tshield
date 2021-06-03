Feature: Save response on call real grpc and return on second call

  Scenario: Save response body
    Given a valid gRPC method "say_hello" defined in "Helloworld::Greeter"
    When this method called throught tshield with request "Helloworld::HelloRequest"
    Then grpc response should be saved in "requests/grpc/Helloworld::Greeter/say_hello/5759534c6594b9eb7a22bbb40ba8d6c887a7e3f0"

  Scenario: Save response body in a session
    Given a valid gRPC method "say_hello" defined in "Helloworld::Greeter"
    And in session "vcr-session"
    When this method called throught tshield with request "Helloworld::HelloRequest"
    Then grpc response should be saved in "requests/grpc/vcr-session/Helloworld::Greeter/say_hello/5759534c6594b9eb7a22bbb40ba8d6c887a7e3f0"

@windows
  Scenario: Save response body using windows compatibility mode
  Given tshield has started with "windows_compatibility.yml" config file
  And a valid gRPC method "say_hello" defined in "Helloworld::Greeter"
  When this method called throught tshield with request "Helloworld::HelloRequest"
  Then grpc response should be saved in "requests/grpc/Helloworld%3a%3aGreeter/say_hello/5759534c6594b9eb7a22bbb40ba8d6c887a7e3f0"

@windows
  Scenario: Save response body in a session using windows compatibility mode
    Given tshield has started with "windows_compatibility.yml" config file
    And a valid gRPC method "say_hello" defined in "Helloworld::Greeter"
    And in session "vcr-session"
    When this method called throught tshield with request "Helloworld::HelloRequest"
    Then grpc response should be saved in "requests/grpc/vcr-session/Helloworld%3a%3aGreeter/say_hello/5759534c6594b9eb7a22bbb40ba8d6c887a7e3f0"

@grpc_service_off
  Scenario: Save only original_request in a session when GRPC service is unavailable
    Given a valid gRPC method "say_hello" defined in "Helloworld::Greeter"
    And in session "vcr-session"
    When this method called throught tshield with request "Helloworld::HelloRequest" expecting an connection error
    Then grpc original_request file should be saved in "requests/grpc/vcr-session/Helloworld::Greeter/say_hello/5759534c6594b9eb7a22bbb40ba8d6c887a7e3f0"
    But grpc response file should not be saved in "requests/grpc/vcr-session/Helloworld::Greeter/say_hello/5759534c6594b9eb7a22bbb40ba8d6c887a7e3f0"
