require 'httparty'
require 'json'
require 'byebug'

require 'tshield/configuration'
require 'tshield/counter'
require 'tshield/options'
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
      if not (@options[:raw_query].nil? or @options[:raw_query].empty?)
        @path = "#{@path}?#{@options[:raw_query]}"
      end

      @url = "#{domain}#{@path}"

      if exists
        @response = get_current_response  
        @response.original = false
      else
        raw = HTTParty.send("#{method}", @url, @options)
        save(raw)
        @response = TShield::Response.new(raw.body, raw.header)
        @response.original = true
      end
      debugger if TShield::Options.instance.break?(path: @path, moment: :after)
      @response
    end

    private
    def domain
      @domain ||= @configuration.get_domain_for(@path)
    end

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
      return @destiny_path if @destiny_path

      request_path = File.join('requests')
      Dir.mkdir(request_path) unless File.exists?(request_path)

      domain_path = File.join(request_path, domain.gsub(/.*:\/\//, ''))
      Dir.mkdir(domain_path) unless File.exists?(domain_path)

      path_path = File.join(domain_path, @path.gsub(/\//, '-').gsub(/^-/, ''))
      Dir.mkdir(path_path) unless File.exists?(path_path)

      method_path = File.join(path_path, method)
      Dir.mkdir(method_path) unless File.exists?(method_path)

      @destiny_path = File.join(method_path, 'requests.json')
    end

    def write(content)
      f = File.open(destiny, 'w')
      f.write(content.to_json)
      f.close
    end

  end

end

