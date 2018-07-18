require 'yaml'

require 'tshield/after_filter'
require 'tshield/before_filter'

module TShield
  class Configuration

    attr_accessor :request
    attr_accessor :domains
    attr_accessor :tcp_servers
    attr_writer :session_path

    def initialize(attributes)
      attributes.each do |key, value|
        send("#{key}=", value)
      end

      if File.exists?('filters')
        Dir.entries('filters').each do |entry|
          next if entry =~ /^\.\.?$/
          puts "loading filter #{entry}"
          entry.gsub!('.rb', '')
          require File.join('.', 'filters', entry)
        end
      end
    end

    def self.singleton
      @@configuration ||= load_configuration
    end

    def get_domain_for(path)
      domains.each do |url, config|
        config['paths'].each { |p| return url if path =~ Regexp.new(p) }
      end
      nil
    end

    def get_headers(domain)
      domains[domain]['headers'] || {}
    end

    def get_name(domain)
      domains[domain]['name'] || domain.gsub(/.*:\/\//, '')
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

    def session_path
      @session_path || '/sessions'
    end

    def admin_session_path
      @admin_session_path || '/admin/sessions'
    end

    def admin_request_path
      @admin_request_path || '/admin/requests'
    end

    private
    def self.load_configuration
      config_path = File.join('config', 'tshield.yml')
      file = File.open(config_path)
      configs = YAML::load(file.read)
      Configuration.new(configs)
    end

  end
end

