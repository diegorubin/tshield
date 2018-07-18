require 'httparty'
require 'json'
require 'byebug'

require 'digest/sha1'

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
      @options[:timeout] =  @configuration.request['timeout']
      @options[:verify] =  @configuration.request['verify_ssl']
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
        @method = method
        @configuration.get_before_filters(domain).each do |filter|
          @method, @url, @options = filter.new.filter(@method, @url, @options)
        end

        raw = HTTParty.send("#{@method}", @url, @options)

        @configuration.get_after_filters(domain).each do |filter|
          raw = filter.new.filter(raw)
        end

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

    def name
      @name ||= @configuration.get_name(domain)
    end

    def method
      @options[:method].downcase
    end

    def save(raw_response)
      headers = {}
      raw_response.headers.each {|k,v| headers[k] = v}

      content = {
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
      @content ||= JSON.parse(File.open(destiny).read)
    end

    def file_exists
      session = current_session
      @content_idx = session ? session[:counter].current(@path, method) : 0
      File.exists?(destiny)
    end

    def exists
      file_exists && @configuration.cache_request?(domain)
    end

    def get_current_response
      TShield::Response.new(content['body'], content['headers'] || [], content['status'] || 200) 
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

      name_path = File.join(request_path, name)
      Dir.mkdir(name_path) unless File.exists?(name_path)

      path_path = File.join(name_path, safe_dir(@path))
      Dir.mkdir(path_path) unless File.exists?(path_path)

      method_path = File.join(path_path, method)
      Dir.mkdir(method_path) unless File.exists?(method_path)

      @destiny_path = File.join(method_path, "#{@content_idx}.json")
    end

    def write(content)
      f = File.open(destiny, 'w')
      f.write(content.to_json)
      f.close
    end

    def safe_dir(url)
      if url.size > 225
        path = url.gsub(/(\?.*)/, '')
        params = Digest::SHA1.hexdigest $1
        "#{path.gsub(/\//, '-').gsub(/^-/, '')}?#{params}"
      else
        url.gsub(/\//, '-').gsub(/^-/, '')
      end
    end

  end

end

