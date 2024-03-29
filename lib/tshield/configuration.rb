# frozen_string_literal: true

require 'yaml'

require 'tshield/errors'
require 'tshield/after_filter'
require 'tshield/before_filter'
require 'tshield/options'
require 'tshield/logger'

module TShield
  # Class for read configuration file
  class Configuration
    # Configuration file
    #
    # Possible attributes
    # request:
    #   timeout: wait time for real service in seconds
    #   verify_ssl: ignores invalid ssl if false
    # domains:
    #   'url':
    #     name: Name to identify the domain in the generated files
    #     headers: Object to translate received header in tshield to send to
    #              original service. Sinatra change keys. Example:
    #                HTTP_AUTHORIZATION should be mapped to Authorization
    #                (NEED IMPROVEMENT github-issue #https://github.com/diegorubin/tshield/issues/17)
    #     not_save_headers: List of headers that should be ignored in generated
    #                       file
    #     ignore_query_params: List of params that should be ignored in
    #                          generated directory
    #
    attr_reader :request
    attr_reader :domains, :tcp_servers, :session_path, :windows_compatibility

    def initialize(attributes)
      attributes.each { |key, value| instance_variable_set("@#{key}", value) }

      return unless File.exist?('filters')

      Dir.entries('filters').each do |entry|
        next if entry =~ /^\.\.?$/

        TShield.logger.info("loading filter #{entry}")
        entry.gsub!('.rb', '')

        require File.join('.', 'filters', entry)
      end
    end

    def self.singleton
      @singleton ||= load_configuration
    end

    def self.clear
      @singleton = nil
    end

    def get_domain_for(path)
      domains.each do |url, config|
        result = self.class.get_url_for_domain_by_path(path, config)
        return url if result
      end
      raise ConfigurationNotFoundError.new("Domain not found for path #{path}")
    end

    def windows_compatibility?
      windows_compatibility || false
    end

    def get_headers(domain)
      (domains[domain] || {})['headers'] || {}
    end

    def get_name(domain)
      domains[domain]['name'] || domain.gsub(%r{.*://}, '')
    end

    def get_before_filters(domain)
      get_filters(domain)
        .select { |klass| klass.ancestors.include?(TShield::BeforeFilter) }
    end

    def get_after_filters(domain)
      get_filters(domain)
        .select { |klass| klass.ancestors.include?(TShield::AfterFilter) }
    end

    def cache_request?(domain)
      domains[domain]['cache_request'] || true
    end

    def get_filters(domain)
      begin
        (domains[domain]['filters'] || [])
          .collect { |filter| Class.const_get(filter) }
      rescue
        puts "Error loading filters for domain #{domain}"
      end
    end

    def get_excluded_headers(domain)
      domains[domain]['excluded_headers'] || []
    end

    def not_save_headers(domain)
      domains[domain]['not_save_headers'] || []
    end

    def send_header_content_type(domain)
      return domains[domain]['send_header_content_type'] != false if domains[domain]

      true
    end

    def read_session_path
      session_path || '/sessions'
    end

    def grpc
      defaults = { 'port' => 5678, 'proto_dir' => 'proto', 'services' => {} }
      defaults.merge(@grpc || {})
    end

    def self.get_url_for_domain_by_path(path, config)
      config['paths'].select { |pattern| path =~ Regexp.new(pattern) }[0]
    end

    def self.read_configuration_file(config_path)
      configs = YAML.safe_load(File.open(config_path).read)
      Configuration.new(configs)
    end

    def self.load_configuration
      configuration_file = TShield::Options.instance.configuration_file
      read_configuration_file(configuration_file)
    rescue Errno::ENOENT => e
      TShield.logger.fatal(
        "Load configuration file #{configuration_file} failed!\n#{e}"
      )
      raise 'Startup aborted'
    end

    def get_delay(domain, path)
      ((domains[domain] || {})['delay'] || {})[path] || 0
    end
  end
end
