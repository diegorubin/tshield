require 'httparty'
require 'json'
require 'byebug'

require 'tshield/configuration'
require 'tshield/options'
require 'tshield/response'
require 'tshield/sessions'

module TShield

  class Request

    attr_reader :response

    def initialize(path, options = {})
      @path = path
      @options = options 
      @configuration = TShield::Configuration.singleton
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
        @response = save(raw)
        @response.original = true
      end
      current_session[:counter].add(@path, method) if current_session
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
      headers = {}
      raw_response.headers.each {|k,v| headers[k] = v}

      content << {
        body: raw_response.body, 
        status: raw_response.code,
        headers: headers
      }

      write(content)

      TShield::Response.new(raw_response.body, headers, raw_response.code)
    end

    def current_session
      TShield::Sessions.current(@options[:ip])
    end

    def content
      @content ||= file_exists ? JSON.parse(File.open(destiny).read) : []
    end

    def file_exists
      File.exists?(destiny)
    end

    def exists
      file_exists && include_current_response?
    end

    def include_current_response?
      session = current_session
      @content_idx = session ? session[:counter].current(@path, method) : 0
      not content[@content_idx].nil?
    end

    def get_current_response
      current = content[@content_idx || 0]
      TShield::Response.new(current['body'], current['headers'] || [], current['status'] || 200) 
    end

    def key
      @key ||= Digest::SHA1.hexdigest "#{@url}|#{method}"
    end

    def destiny
      return @destiny_path if @destiny_path

      request_path = File.join('requests')
      Dir.mkdir(request_path) unless File.exists?(request_path)

      if session = current_session
        request_path = File.join(request_path, session[:name])
        Dir.mkdir(request_path) unless File.exists?(request_path)
      end

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

