require 'httparty'
require 'json'

require 'tshield/configuration'

module TShield

  class Response

    def initialize(path, options = {})
      @path = path
      @options = options 
      @configuration = TShield::Configuration.singleton
    end

    def request
    end

    def send_response
      @content
    end

  end

end

