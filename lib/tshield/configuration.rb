module TShield
  class Configuration

    attr_accessor :domains

    def initialize(attributes)
      attributes.each do |key, value|
        send("#{key}=", value)
      end
    end

    def self.singleton
      @@configuration ||= load_configuration
    end

    def get_domain_for(path)
      domains.each do |url, paths|
        return url if paths.include?(path)
      end
      nil
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

