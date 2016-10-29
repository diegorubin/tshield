require 'httparty'
require 'json'
require 'digest/sha1'

require 'tshield/configuration'
require 'tshield/response'

module TShield

  class Request

    def initialize(path, options = {})
      @path = path
      @options = options 
      @configuration = TShield::Configuration.singleton
      request
    end

    def request
      @url = "#{@configuration.get_domain_for(@path)}/#{@path}"

      if exists
      else
        @response = HTTParty.send("#{method}", @url)
        save
      end
    end

    def response
      TShield::Response.new(@response.body, @response.header)
    end

    private
    def method
      @options[:method].downcase
    end

    def save
      content = []
      if exists
        content = JSON.parse(File.open(destiny))
      end

      puts @response.header

      content << {body: @response.body, header: @response.header}
      write(content)

      content
    end

    def exists
      File.exists?(destiny)
    end

    def key
      @key ||= Digest::SHA1.hexdigest "#{@url}|#{method}"
    end

    def destiny
      destiny_path = File.join('requests')
      Dir.mkdir('requests') unless File.exists?(destiny_path)
      File.join(destiny_path, key)
    end

    def write(content)
      f = File.open(destiny, 'w')
      f.write(content.to_json)
      f.close
    end

  end

end

