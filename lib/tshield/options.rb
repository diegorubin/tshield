# frozen_string_literal: true

require 'optparse'

require 'tshield/logger'
require 'tshield/version'

module TShield
  # Options for command line
  class Options
    attr_reader :debug

    def self.init
      @instance = TShield::Options.new
    end

    def self.instance
      @instance || TShield::Options.new
    end

    def initialize
      @options = {}
      parse
    end

    def break?(args = {})
      check_breakpoint(args)
    end

    def configuration_file
      @options.fetch(:configuration_file, 'config/tshield.yml')
    end

    private

    def check_breakpoint(args)
      check_breakpoint_moment(args)
    end

    def check_breakpoint_moment(args)
      @options["#{args[:moment]}_pattern".to_sym] =~ args[:path]
    end

    def register_before_pattern(opts)
      opts.on('-b', '--break-before-request [PATTERN]',
              'Breakpoint before request') do |pattern|
        @options[:before_pattern] = Regexp.new(pattern)
      end
    end

    def register_after_pattern(opts)
      opts.on('-a', '--break-after-request [PATTERN]',
              'Breakpoint after request') do |pattern|
        @options[:after_pattern] = Regexp.new(pattern)
      end
    end

    def register_configuration(opts)
      opts.on('-c', '--configuration [FILE]',
              'Configuration File') do |file|
        @options[:configuration_file] = file
      end
    end

    def register_patterns(opts)
      register_before_pattern(opts)
      register_after_pattern(opts)
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
      register_patterns(opts)
      register_version(opts)
      register_help(opts)
    end
  end
end
