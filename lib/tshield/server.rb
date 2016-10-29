require 'sinatra'

require 'tshield/request'

module TShield
  class Server < Sinatra::Base

    configure :production, :development do
      enable :logging
    end
 
    PATHP = /([a-zA-Z\/\.-]+)/
    
    get (PATHP) do
      treat(params, headers, request)
    end

    post (PATHP) do
      treat(params, headers, request)
    end

    put (PATHP) do
      treat(params, headers, request)
    end

    patch (PATHP) do
      treat(params, headers, request)
    end

    head (PATHP) do
      treat(params, headers, request)
    end

    private
    def treat(params, headers, request)

      method = request.request_method
      request_content_type = request.content_type
      path = params.fetch('captures', [])[0]

      options = {
        method: method,
        headers: headers
      }

      logger.info(
        "method=#{method} path=#{path} content-type=#{request_content_type}")

      set_content_type content_type
      response = TShield::Request.new(path, options).response
      response.body
    end

    def set_content_type(request_content_type)
      content_type :json
    end

  end
end

