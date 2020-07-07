# frozen_string_literal: true

module TShield
  module Grpc
    module VCR
      def handler_in_vcr_mode(method_name, request, options)
        module_name = options['module']

        response = saved_response(module_name, method_name, request)
        return response if response

        client_class = Object.const_get("#{module_name}::Stub")
        client_instance = client_class.new(options['hostname'], :this_channel_is_insecure)
        response = client_instance.send(method_name, request)
        save_request_and_response(request, response)
        response
      end

      def saved_response(module_name, method_name, request)
        create_destiny(module_name, method_name, request)
        response_file = File.join(@complete_path, 'response')
        return false unless File.exist? response_file

        content = JSON.parse File.open(response_file).read
        response_class = File.open(File.join(@complete_path, 'response_class')).read.strip
        Kernel.const_get(response_class).new(content)
      end

      def save_request_and_response(request, response)
        save_request(request)
        save_response(response)
      end

      def save_request(request)
        file = File.open(File.join(@complete_path, 'original_request'), 'w')
        file.puts request.to_json
        file.close
      end

      def save_response(response)
        file = File.open(File.join(@complete_path, 'response'), 'w')
        file.puts response.to_json
        file.close

        response_class = File.open(File.join(@complete_path, 'response_class'), 'w')
        response_class.puts response.class.to_s
        response_class.close
      end

      def complete_path(module_name, method_name, request)
        return @complete_path if @complete_path

        @complete_path = ['requests', 'grpc', module_name, method_name.to_s, hexdigest(request)]
      end

      def create_destiny(module_name, method_name, request)
        current_path = []
        complete_path(module_name, method_name, request).each do |path|
          current_path << path
          destiny = File.join current_path
          Dir.mkdir destiny unless File.exist? destiny
        end
      end

      def hexdigest(request)
        Digest::SHA1.hexdigest request.to_json
      end
    end
  end
end
