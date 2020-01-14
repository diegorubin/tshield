# frozen_string_literal: true

require 'httparty'
require 'json'
require 'byebug'

require 'digest/sha1'

require 'tshield/configuration'
require 'tshield/options'
require 'tshield/request'
require 'tshield/response'

module TShield
  # Module to write and read saved responses
  class RequestVCR < TShield::Request
    def initialize(path, options = {})
      super()
      @path = path
      @options = options

      request_configuration = configuration.request
      @options[:timeout] = request_configuration['timeout']
      @options[:verify] = request_configuration['verify_ssl']
      request
    end

    def request
      raw_query = @options[:raw_query]
      @path = "#{@path}?#{raw_query}" unless !raw_query || raw_query.empty?

      @url = "#{domain}#{@path}"

      configuration.get_before_filters(domain).each do |filter|
        _method, @url, @options = filter.new.filter(method, @url, @options)
      end

      if exists
        response.original = false
        resp = response
      else
        raw = HTTParty.send(method.to_s, @url, @options)

        original_response = save(raw)
        original_response.original = true
        resp = original_response
      end

      configuration.get_after_filters(domain).each do |filter|
        resp = filter.new.filter(resp)
      end
      resp
    end

    def response
      @response ||= TShield::Response.new(saved_content['body'],
                                          saved_content['headers'] || [],
                                          saved_content['status'] || 200)
    end

    private

    def domain
      @domain ||= configuration.get_domain_for(@path)
    end

    def name
      @name ||= configuration.get_name(domain)
    end

    def method
      @method ||= @options[:method].downcase
    end

    def save(raw_response)
      headers = {}
      raw_response.headers.each do |k, v|
        headers[k] = v unless configuration.not_save_headers(domain).include? k
      end

      content = {
        body: raw_response.body,
        status: raw_response.code,
        headers: headers
      }

      write(content)

      TShield::Response.new(raw_response.body, headers, raw_response.code)
    end

    def saved_content
      return @saved_content if @saved_content

      @saved_content = JSON.parse(File.open(headers_destiny).read)
      @saved_content['body'] = File.open(content_destiny).read unless @saved_content['body']
      @saved_content
    end

    def file_exists
      File.exist?(content_destiny)
    end

    def exists
      file_exists && configuration.cache_request?(domain)
    end

    def key
      @key ||= Digest::SHA1.hexdigest "#{@url}|#{method}"
    end

    def write(content)
      content_file = File.open(content_destiny, 'w')
      content_file.write(content[:body])
      content_file.close

      body = content.delete :body

      headers_file = File.open(headers_destiny, 'w')
      headers_file.write(JSON.pretty_generate(content))
      headers_file.close

      content[:body] = body
    end

    def safe_dir(url)
      if url.size > 225
        path = url.gsub(/(\?.*)/, '')
        params = Digest::SHA1.hexdigest Regexp.last_match(1)
        "#{path.gsub(%r{/}, '-').gsub(/^-/, '')}?#{params}"
      else
        url.gsub(%r{/}, '-').gsub(/^-/, '')
      end
    end
  end
end
