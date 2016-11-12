require 'yaml'

module TShield
  class Configuration

    attr_accessor :domains
    attr_writer :session_path

    def initialize(attributes)
      attributes.each do |key, value|
        send("#{key}=", value)
      end
    end

    def self.singleton
      @@configuration ||= load_configuration
    end

    def get_domain_for(path)
      domains.each do |url, config|
        config['paths'].each { |p| return url if path =~ Regexp.new(p)  }
      end
      nil
    end

    def get_headers(domain)
      domains[domain]['headers'] || {}
    end

    def get_excluded_headers(domain)
      domains[domain]['excluded_headers'] || []
    end

    def session_path
      @session_path ||= '/sessions'
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

