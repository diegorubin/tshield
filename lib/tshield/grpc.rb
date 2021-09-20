# frozen_string_literal: false

require 'grpc'

require 'tshield/configuration'
require 'tshield/grpc/vcr'
require 'pry-byebug'

module TShield
  module Grpc
    module RequestHandler
      include TShield::Grpc::VCR
      def handler(method_name, request, parameters)
        options = self.class.options
        handler_in_vcr_mode(method_name, request, parameters, options)
      end
    end

    def self.run!
      @configuration = TShield::Configuration.singleton.grpc

      lib_dir = File.join(Dir.pwd, @configuration['proto_dir'])
      $LOAD_PATH.unshift(lib_dir) unless $LOAD_PATH.include?(lib_dir)

      TShield.logger.info("loading proto files from #{lib_dir}")

      bind = "0.0.0.0:#{@configuration['port']}"
      TShield.logger.info("Starting gRPC server in #{bind}")

      server = GRPC::RpcServer.new
      server.add_http2_port(bind, :this_port_is_insecure)

      services = load_services(@configuration['services'])
      services.each do |class_service|
        class_service.include RequestHandler
        server.handle(class_service)
      end

      server.run_till_terminated_or_interrupted([1, 'int', 'SIGQUIT']) unless services.empty?
    end

    def self.load_services(services)
      handlers = []
      number_of_handlers = 0
      services.each do |file, options|

        require file

        base = Object.const_get("#{options['module']}::Service")
        number_of_handlers += 1

        implementation = build_handler(base, base.rpc_descs, number_of_handlers, options)
        handlers << implementation
      end
      handlers
    end

    def self.build_handler(base, descriptions, number_of_handlers, options)
      handler = Class.new(base) do
        class << self
          attr_accessor :options
        end
        descriptions.each do |service_name, description|
          puts description
          method_name = service_name.to_s.underscore.to_sym
          define_method(method_name) do |request, parameters|
            handler(__method__, request, parameters)
          end
        end
      end
      handler.options = options
      TShield::Grpc.const_set "GrpcService#{number_of_handlers}", handler
    end
  end
end
