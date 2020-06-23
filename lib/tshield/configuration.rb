# frozen_string_literal: true

require 'yaml'

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
    attr_reader :domains
    attr_reader :grpc
    attr_reader :tcp_servers
    attr_reader :session_path

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
      nil
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
      (domains[domain]['filters'] || [])
        .collect { |filter| Class.const_get(filter) }
    end

    def get_excluded_headers(domain)
      domains[domain]['excluded_headers'] || []
    end

    def not_save_headers(domain)
      domains[domain]['not_save_headers'] || []
    end

    def read_session_path
      session_path || '/sessions'
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
  end
end
