# frozen_string_literal: true

require 'tshield/configuration'
require 'tshield/sessions'

module TShield
  module Grpc
    # Grpc vcr module
    module VCR
      # Path file to save Grpc request/response
      class FilePath
        attr_reader :path, :count

        def initialize(path, count)
          @path = path
          @count = count
        end
      end

      def initialize
        @configuration = TShield::Configuration.singleton
      end

      def handler_in_vcr_mode(method_name, request, parameters, options)
        parameters.peer =~ /ipv6:\[(.+?)\]|ipv4:(.+?):/
        peer = Regexp.last_match(1) || Regexp.last_match(2)

        TShield.logger.info("request from #{parameters.peer}")
        @session = TShield::Sessions.current(peer)
        @digest = hexdigest(request)
        counter = @session ? request_count.current(@digest) : 0

        TShield.logger.info("grpc using session #{@session || 'default'}")
        module_name = options['module']

        path = create_destiny(module_name, method_name)
        @file_path = FilePath.new(path, counter)
        save_request(request)
        response = {}
        saved_error
        begin
          response = saved_response
          if response
            TShield.logger.info("returning saved response for request #{request.to_json} saved into #{@digest}")
            request_count.add(@digest) if @session
            return response
          end

          response = send_request(request, module_name, options, method_name)
          save_response(response)
        rescue GRPC::BadStatus => e
          save_error({ code: e.code, details: e.details })
          raise e
        end
        request_count.add(@digest) if @session
        response
      end

      def send_request(request, module_name, options, method_name)
        TShield.logger.info("calling server to get response for #{request.to_json}")
        client_class = Object.const_get("#{module_name}::Stub")
        client_instance = client_class.new(options['hostname'], :this_channel_is_insecure)
        client_instance.send(method_name, request)
      end

      def request_count
        @session[:grpc_counter]
      end

      def encode_colon(value)
        value.gsub(':', '%3a')
      end

      def saved_response
        response_file = File.join(@file_path.path, "#{@file_path.count}.response")
        return false unless File.exist? response_file

        content = JSON.parse File.open(response_file).read
        response_class = File.open(File.join(@file_path.path, "#{@file_path.count}.response_class")).read.strip
        Kernel.const_get(response_class).new(content)
      end

      def saved_error
        error_file = File.join(@file_path.path, "#{@file_path.count}.error")
        return false unless File.exist? error_file

        request_count.add(@digest) if @session
        content = JSON.parse File.open(error_file).read
        grpc_error = GRPC::BadStatus.new(content['code'], content['details'])
        raise grpc_error
      end

      def save_request(request)
        file = File.open(File.join(@file_path.path, "#{@file_path.count}.original_request"), 'w')
        file.puts request.to_json
        file.close
      end

      def save_error(error)
        file = File.open(File.join(@file_path.path, "#{@file_path.count}.error"), 'w')
        file.puts error.to_json
        file.close
        request_count.add(@digest) if @session
      end

      def save_response(response)
        file = File.open(File.join(@file_path.path, "#{@file_path.count}.response"), 'w')
        file.puts response.to_json
        file.close

        response_class = File.open(File.join(@file_path.path, "#{@file_path.count}.response_class"), 'w')
        response_class.puts response.class.to_s
        response_class.close
      end

      def complete_path(module_name, method_name)
        @session_name = (@session || {})[:name]
        module_name = @configuration.windows_compatibility? ? encode_colon(module_name) : module_name
        ['requests', @session_name, module_name, method_name.to_s, @digest].compact
      end

      def create_destiny(module_name, method_name)
        current_path = []

        path = complete_path(module_name, method_name)
        TShield.logger.info("using path #{path}")
        path.each do |inner_path|
          current_path << inner_path
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
