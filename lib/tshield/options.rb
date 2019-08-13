# frozen_string_literal: true

require 'optparse'

require 'tshield/logger'
require 'tshield/version'

module TShield
  # Options for command line
  class Options
    attr_reader :debug

    def self.init(options = {})
      @instance = TShield::Options.new(options)
    end

    def self.instance
      @instance || TShield::Options.new
    end

    def initialize(options = {})
      @options = {}
      parse unless options[:skip_parse]
    end

    def configuration_file
      @options.fetch(:configuration_file, 'config/tshield.yml')
    end

    def port
      @options.fetch(:port, 4567)
    end

    private

    def register_port(opts)
      opts.on('-p', '--port [PORT]',
              'Sinatra port') do |port|
        @options[:port] = port.to_i
      end
    end

    def register_configuration(opts)
      opts.on('-c', '--configuration [FILE]',
              'Configuration File') do |file|
        @options[:configuration_file] = file
      end
    end

    def register_version(opts)
      opts.on('-v', '--version', 'Show version') do
        TShield.logger.info(TShield::Version.to_s)
        exit
      end
    end

    def register_help(opts)
      opts.on_tail('-h', '--help', 'Show this message') do
        puts opts
        exit
      end
    end

    def parse
      OptionParser.new do |opts|
        opts.banner = 'Usage: tshield [options]'
        register(opts)
      end.parse!
    end

    def register(opts)
      register_configuration(opts)
      register_version(opts)
      register_port(opts)
      register_help(opts)
    end
  end
end
