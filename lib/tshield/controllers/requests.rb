# frozen_string_literal: true

require 'sinatra'

require 'tshield/controllers/helpers/session_helpers'
require 'tshield/options'
require 'tshield/configuration'
require 'tshield/request_matching'
require 'tshield/request_vcr'
require 'tshield/sessions'

module TShield
  module Controllers
    # Requests Handler
    module Requests
      PATHP = %r{([a-zA-Z0-9/\._-]+)}.freeze

      def self.registered(app)
        app.configure :production, :development do
          app.enable :logging
        end

        %w[get post put patch head delete].each do |http_method|
          app.send(http_method, PATHP) do
            treat(params, request, response)
          end
        end
      end

      # Requests Handler Helpers
      module Helpers
        def self.build_headers(request)
          headers = request.env.select { |key, _value| key =~ /HTTP/ }
          headers['Content-Type'] = request.content_type || 'application/json'
          headers
        end

        def treat(params, request, _response)
          path = params.fetch('captures', [])[0]
          callid = "#{path}?#{request.env['QUERY_STRING']}"

          method = request.request_method
          request_content_type = request.content_type

          session_name = TShield::Controllers::Helpers::SessionHelpers.current_session_name(request)
          session_call = TShield::Controllers::Helpers::SessionHelpers
                         .current_session_call(request, callid, method)

          options = {
            method: method,
            headers: Helpers.build_headers(request),
            raw_query: request.env['QUERY_STRING'],
            session: session_name,
            call: session_call,
            ip: request.ip
          }

          if %w[POST PUT PATCH].include? method
            result = request.body.read.encode('UTF-8',
                                              invalid: :replace,
                                              undef: :replace,
                                              replace: '')
            options[:body] = result
          end
          api_response = TShield::RequestMatching.new(path, options.clone).match_request

          unless api_response
            add_headers(headers, path)

            api_response ||= TShield::RequestVCR.new(path, options.clone).response
            api_response.headers.reject! do |key, _v|
              configuration.get_excluded_headers(domain(path)).include?(key)
            end
          end

          logger.info(
            "original=#{api_response.original} method=#{method} path=#{path} "\
            "content-type=#{request_content_type} "\
            "session=#{session_name} call=#{session_call}"
          )
          TShield::Controllers::Helpers::SessionHelpers.update_session_call(request, callid, method)

          status api_response.status
          headers api_response.headers
          body api_response.body
        end

        def add_headers(headers, path)
          (configuration.get_headers(domain(path)) || {}).each do |source, destiny|
            headers[destiny] = request.env[source] if request.env[source]
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
