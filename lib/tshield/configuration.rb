# frozen_string_literal: true

require 'yaml'

require 'tshield/after_filter'
require 'tshield/before_filter'
require 'tshield/logger'

module TShield
  # Class for read configuration file
  class Configuration
    attr_accessor :request
    attr_accessor :domains
    attr_accessor :tcp_servers

    attr_reader :admin_request_path

    attr_writer :session_path

    def initialize(attributes)
      attributes.each { |key, value| send("#{key}=", value) }

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
        config['paths'].each do |pattern|
          return url if path =~ Regexp.new(pattern)
        end
      end
      nil
    end

    def get_headers(domain)
      domains[domain]['headers'] || {}
    end

    def get_name(domain)
      domains[domain]['name'] || domain.gsub(%r{.*://}, '')
    end

    def get_before_filters(domain)
      get_filters(domain)
        .select { |k| k.ancestors.include?(TShield::BeforeFilter) }
    end

    def get_after_filters(domain)
      get_filters(domain)
        .select { |k| k.ancestors.include?(TShield::AfterFilter) }
    end

    def cache_request?(domain)
      return true unless domains[domain].include?('cache_request')

      domains[domain]['cache_request']
    end

    def get_filters(domain)
      (domains[domain]['filters'] || [])
        .collect { |f| Class.const_get(f) }
    end

    def get_excluded_headers(domain)
      domains[domain]['excluded_headers'] || []
    end

    def not_save_headers(domain)
      domains[domain]['not_save_headers'] || []
    end

    def session_path
      @session_path || '/sessions'
    end

    def admin_session_path
      @admin_session_path || '/admin/sessions'
    end

    def admin_request_path
      @admin_request_path || '/admin/requests'
    end

    def self.load_configuration
      config_path = File.join('config', 'tshield.yml')
      file = File.open(config_path)
      configs = YAML.safe_load(file.read)
      Configuration.new(configs)
    rescue Errno::ENOENT => e
      TShield.logger.fatal('Load configuration file config/tshield.yml failed!')
      TShield.logger.fatal(e)
      raise 'Startup aborted'
    end
  end
end
