# encoding: utf-8

require 'sinatra'

require 'byebug'

require 'tshield/options'
require 'tshield/configuration'
require 'tshield/request'

module TShield
  module Controllers
    module Requests
      PATHP = /([a-zA-Z\/\.-_]+)/

      def self.registered(app)
        app.configure :production, :development do
          app.enable :logging
        end

        
        app.get (PATHP) do
          treat(params, request)
        end

        app.post (PATHP) do
          treat(params, request)
        end

        app.put (PATHP) do
          treat(params, request)
        end

        app.patch (PATHP) do
          treat(params, request)
        end

        app.head (PATHP) do
          treat(params, request)
        end
      end

      module Helpers
        def treat(params, request)
          path = params.fetch('captures', [])[0]

          debugger if TShield::Options.instance.break?(path: path, moment: :before)

          method = request.request_method
          request_content_type = request.content_type

          headers = {
            'Content-Type' => request.content_type || 'application/json'
          }

          add_headers(headers, path)

          options = {
            method: method,
            headers: headers,
            raw_query: request.env['QUERY_STRING'],
            ip: request.ip
          }

          if ['POST', 'PUT', 'PATCH'].include? method
            result = request.body.read.encode('UTF-8', {
              :invalid => :replace,
              :undef   => :replace,
              :replace => ''
            })
            options[:body] = result
          end

          set_content_type content_type

          response = TShield::Request.new(path, options).response

          logger.info(
            "original=#{response.original} method=#{method} path=#{path} content-type=#{request_content_type}")

          response.body
        end

        def set_content_type(request_content_type)
          content_type :json
        end

        def add_headers(headers, path)
          @configuration ||= TShield::Configuration.singleton
          domain = @configuration.get_domain_for(path)
          @configuration.get_headers(domain).each do |source, destiny| 
            headers[destiny] = request.env[source] unless request.env[source].nil?
          end
        end
      end
    end
  end
end

