# frozen_string_literal: false

require 'grpc'
require 'byebug'

require 'tshield/configuration'

module TShield
  class Grpc
    def self.run!
      @configuration = TShield::Configuration.singleton.grpc

      lib_dir = File.join(Dir.pwd, @configuration['proto_dir'])
      $LOAD_PATH.unshift(lib_dir) unless $LOAD_PATH.include?(lib_dir)

      TShield.logger.info("loading proto files from #{lib_dir}")

      bind = "0.0.0.0:#{@configuration['port']}"

      server = GRPC::RpcServer.new
      server.add_http2_port(bind, :this_port_is_insecure)

      services = load_services(@configuration['services'])
      services.each do |class_service|
        server.handle(class_service)
      end

      server.run unless services.empty?
    end

    def self.load_services(services)
      implementations = []
      number_of_implementations = 0
      services.each do |file, options|
        require file

        base = Object.const_get("#{options['module']}::Service")
        number_of_implementations += 1

        implementation = Class.new(base) do
          base.rpc_descs.each do |method_name, _description|
            method_name = method_name.to_s.underscore.to_sym
            define_method(method_name) do |request, _unused_call|
              client_class = Object.const_get("#{options['module']}::Stub")
              client_instance = client_class.new(options['hostname'], :this_channel_is_insecure)
              client_instance.send(method_name, request)
            end
          end
        end
        Object.const_set "GrpcService#{number_of_implementations}", implementation

        implementations << implementation
      end
      implementations
    end
  end
end
