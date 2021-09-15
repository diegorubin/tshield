# frozen_string_literal: true

require 'tshield/configuration'
require 'tshield/sessions'

module TShield
  module Grpc
    module VCR
      @@counter = -1

      def initialize
        @configuration = TShield::Configuration.singleton
      end

      def handler_in_vcr_mode(method_name, request, parameters, options)
        parameters.peer =~ /ipv6:\[(.+?)\]|ipv4:(.+?):/
        peer = Regexp.last_match(1) || Regexp.last_match(2)

        TShield.logger.info("request from #{parameters.peer}")
        @session = TShield::Sessions.current(peer)

        TShield.logger.info("grpc using session #{@session || 'default'}")
        module_name = options['module']

        path = create_destiny(module_name, method_name, request)
        save_request(path, request)
        response = saved_response(path)
        if response
          TShield.logger.info("returning saved response for request #{request.to_json} saved into #{hexdigest(request)}")
          return response
        end

        TShield.logger.info("calling server to get response for #{request.to_json}")
        client_class = Object.const_get("#{module_name}::Stub")
        client_instance = client_class.new(options['hostname'], :this_channel_is_insecure)
        response = client_instance.send(method_name, request)
        save_response(path, response)
        response
      end

      def encode_colon(value)
        value.gsub(':', '%3a')
      end

      def saved_response(path)
        response_file = File.join(path, "#{@@counter}.response")
        return false unless File.exist? response_file

        content = JSON.parse File.open(response_file).read
        response_class = File.open(File.join(path, "#{@@counter}.response_class")).read.strip
        Kernel.const_get(response_class).new(content)
      end

      def save_request(path, request)
        @@counter += 1
        file = File.open(File.join(path, "#{@@counter}.original_request"), 'w')
        file.puts request.to_json
        file.close
      end

      def save_response(path, response)
        file = File.open(File.join(path, "#{@@counter}.response"), 'w')
        file.puts response.to_json
        file.close

        response_class = File.open(File.join(path, "#{@@counter}.response_class"), 'w')
        response_class.puts response.class.to_s
        response_class.close
      end

      def complete_path(module_name, method_name, request)
        @session_name = (@session || {})[:name]
        module_name = @configuration.windows_compatibility? ? encode_colon(module_name) : module_name
        ['requests', 'grpc', @session_name, module_name, method_name.to_s, hexdigest(request)].compact
      end

      def create_destiny(module_name, method_name, request)
        current_path = []

        path = complete_path(module_name, method_name, request)
        TShield.logger.info("using path #{path}")
        path.each do |path|
          current_path << path
          destiny = File.join current_path
          Dir.mkdir destiny unless File.exist? destiny
        end
        path
      end

      def hexdigest(request)
        Digest::SHA1.hexdigest request.to_json
      end
    end
  end
end
