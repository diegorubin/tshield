# frozen_string_literal: true

require 'httparty'
require 'json'

require 'digest/sha1'

require 'tshield/configuration'
require 'tshield/logger'
require 'tshield/options'
require 'tshield/request'
require 'tshield/response'

module TShield
  # Module to write and read saved responses
  class RequestVCR < TShield::Request
    attr_reader :vcr_response

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

      in_session = find_in_sessions
      if in_session
        # TODO: create concept of global session in vcr
        in_session = nil if in_session == 'global'
        @vcr_response = response(in_session)
        @vcr_response.original = false
      else
        TShield.logger.info("calling original service for request with options #{@options}")
        raw = HTTParty.send(method.to_s, @url, @options)

        original_response = save(raw)
        original_response.original = true
        @vcr_response = original_response
      end

      configuration.get_after_filters(domain).each do |filter|
        @vcr_response = filter.new.filter(@vcr_response)
      end
    end

    def response(session)
      response_content = saved_content(session)
      TShield::Response.new(response_content['body'],
                            response_content['headers'] || [],
                            response_content['status'] || 200)
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

    def saved_content(session)
      content = JSON.parse(File.open(headers_destiny(session)).read)
      content['body'] = File.open(content_destiny(session)).read unless content['body']
      content
    end

    def file_exists(session)
      File.exist?(content_destiny(session))
    end

    def find_in_sessions
      in_session = nil

      ([@options[:session]] + (@options[:secondary_sessions] || [])).each do |session|
        if file_exists(session) && configuration.cache_request?(domain)
          in_session = (session || 'global')
          break
        end
        TShield.logger.info("saved response not found in #{session}")
      end
      in_session
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
