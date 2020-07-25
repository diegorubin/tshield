# frozen_string_literal: true

require 'tshield/sessions'

module TShield
  # Base of request mock methods
  class Request
    attr_reader :configuration

    def initialize
      @configuration = TShield::Configuration.singleton
    end

    protected

    def session_destiny(request_path, current_session = nil)
      session = current_session || @options[:session]
      return request_path unless session

      request_path = File.join(request_path, session)
      Dir.mkdir(request_path) unless File.exist?(request_path)
      request_path
    end

    def content_destiny(current_session = nil)
      "#{destiny(current_session)}.content"
    end

    def headers_destiny(current_session = nil)
      "#{destiny(current_session)}.json"
    end

    def destiny(current_session = nil)
      request_path = File.join('requests')
      Dir.mkdir(request_path) unless File.exist?(request_path)

      request_path = session_destiny(request_path, current_session)

      name_path = File.join(request_path, name)
      Dir.mkdir(name_path) unless File.exist?(name_path)

      cleared_path = clear_path(@path)
      path_path = File.join(name_path, safe_dir(cleared_path))

      Dir.mkdir(path_path) unless File.exist?(path_path)

      method_path = File.join(path_path, method)
      Dir.mkdir(method_path) unless File.exist?(method_path)

      File.join(method_path, @options[:call].to_s)
    end

    def clear_path(path)
      skip_query_params = configuration.domains[@domain]['skip_query_params']
      url_path, params = path.split('?')

      return path if !skip_query_params || !params

      cleared_params = params.split('&').select do |param|
        param unless skip_query_params.include?(param.gsub(/=.*?$/, ''))
      end.join('&')

      [url_path, cleared_params].join('?')
    end
  end
end
