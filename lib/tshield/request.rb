require 'httparty'
require 'json'
require 'digest/sha1'

require 'tshield/configuration'
require 'tshield/counter'
require 'tshield/response'

module TShield

  class Request

    attr_reader :response

    def initialize(path, options = {})
      @path = path
      @options = options 
      @configuration = TShield::Configuration.singleton
      @counter = TShield::Counter.singleton
      request
    end

    def request
      @url = "#{@configuration.get_domain_for(@path)}/#{@path}"

      if exists
        @response = get_current_response  
      else
        raw = HTTParty.send("#{method}", @url, @options)
        save(raw)
        @response = TShield::Response.new(raw.body, raw.header)
      end
    end

    private
    def method
      @options[:method].downcase
    end

    def save(raw_response)
      content << {body: raw_response.body}
      write(content)

      content
    end

    def content
      return @content if @content
      @content = []
      if exists
        @content = JSON.parse(File.open(destiny).read)
      end
      @content
    end

    def exists
      File.exists?(destiny) && include_current_response?
    end

    def include_current_response?
      true
    end

    def get_current_response
      current = content[0]
      TShield::Response.new(current['body'], current['header']) 
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

