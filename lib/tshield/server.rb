# encoding: utf-8

require 'sinatra'

require 'tshield/configuration'
require 'tshield/request'

module TShield
  class Server < Sinatra::Base

    configure :production, :development do
      enable :logging
    end

    PATHP = /([a-zA-Z\/\.-_]+)/
    
    get (PATHP) do
      treat(params, request)
    end

    post (PATHP) do
      treat(params, request)
    end

    put (PATHP) do
      treat(params, request)
    end

    patch (PATHP) do
      treat(params, request)
    end

    head (PATHP) do
      treat(params, request)
    end

    private
    def treat(params, request)

      method = request.request_method
      request_content_type = request.content_type
      path = params.fetch('captures', [])[0]

      headers = {
        'Content-Type' => request.content_type || 'application/json'
      }

      add_headers(headers, path)

      options = {
        method: method,
        headers: headers,
        raw_query: request.env['QUERY_STRING']
      }

      if ['POST', 'PUT', 'PATCH'].include? method
        result = request.body.read.encode('UTF-8', {
          :invalid => :replace,
          :undef   => :replace,
          :replace => ''
        })
        options[:body] = result
      end

      logger.info(
        "method=#{method} path=#{path} content-type=#{request_content_type}")

      set_content_type content_type
      response = TShield::Request.new(path, options).response
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

