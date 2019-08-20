# frozen_string_literal: true

require 'sinatra'
require 'byebug'

require 'tshield/options'
require 'tshield/configuration'
require 'tshield/request_matching'
require 'tshield/request_vcr'
require 'tshield/sessions'

module TShield
  module Controllers
    module Requests
      PATHP = %r{([a-zA-Z0-9/\._-]+)}.freeze

      def self.registered(app)
        app.configure :production, :development do
          app.enable :logging
        end

        app.get(PATHP) do
          treat(params, request, response)
        end

        app.post(PATHP) do
          treat(params, request, response)
        end

        app.put(PATHP) do
          treat(params, request, response)
        end

        app.patch(PATHP) do
          treat(params, request, response)
        end

        app.head(PATHP) do
          treat(params, request, response)
        end

        app.delete(PATHP) do
          treat(params, request, response)
        end
      end

      module Helpers
        def self.build_headers(request)
          headers = request.env.select { |key, _value| key =~ /HTTP/ }
          headers['Content-Type'] = request.content_type || 'application/json'
          headers
        end

        def treat(params, request, _response)
          path = params.fetch('captures', [])[0]

          method = request.request_method
          request_content_type = request.content_type

          options = {
            method: method,
            headers: Helpers.build_headers(request),
            raw_query: request.env['QUERY_STRING'],
            ip: request.ip
          }

          if %w[POST PUT PATCH].include? method
            result = request.body.read.encode('UTF-8',
                                              invalid: :replace,
                                              undef: :replace,
                                              replace: '')
            options[:body] = result
          end
          api_response = TShield::RequestMatching.new(path, options).match_request

          unless api_response
            add_headers(headers, path)

            api_response ||= TShield::RequestVCR.new(path, options).response
          end

          logger.info(
            "original=#{api_response.original} method=#{method} path=#{path}"\
            "content-type=#{request_content_type}"\
            "session=#{current_session_name(request)}"
          )

          status api_response.status
          headers api_response.headers.reject { |k, _v| configuration.get_excluded_headers(domain(path)).include?(k) }
          body api_response.body
        end

        def current_session_name(request)
          session = TShield::Sessions.current(request.ip)
          session ? session[:name] : 'no-session'
        end

        def add_headers(headers, path)
          (configuration.get_headers(domain(path)) || {}).each do |source, destiny|
            headers[destiny] = request.env[source] unless request.env[source].nil?
          end
        end

        def configuration
          @configuration ||= TShield::Configuration.singleton
        end

        def domain(path)
          @domain ||= configuration.get_domain_for(path)
        end
      end
    end
  end
end
