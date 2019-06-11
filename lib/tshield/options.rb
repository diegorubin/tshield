# frozen_string_literal: true

require 'optparse'

require 'tshield/version'

module TShield
  class Options
    attr_reader :debug

    def self.init
      @@instance = TShield::Options.new
    end

    def self.instance
      @@instance
    end

    def initialize
      parse
    end

    def break?(args = {})
      check_breakpoint(args)
    end

    private

    def check_breakpoint(args)
      check_breakpoint_moment(args)
    end

    def check_breakpoint_moment(args)
      @options["#{args[:moment]}_pattern".to_sym] =~ args[:path]
    end

    def parse
      @options = {}
      OptionParser.new do |opts|
        opts.banner = 'Usage: tshield [options]'

        opts.on('-b', '--break-before-request [PATTERN]',
                'Breakpoint before request') do |pattern|
          @options[:before_pattern] = Regexp.new(pattern)
        end

        opts.on('-a', '--break-after-request [PATTERN]',
                'Breakpoint after request') do |pattern|
          @options[:after_pattern] = Regexp.new(pattern)
        end

        opts.on('-v', '--version', 'Show version') do
          puts TShield::Version
          exit
        end

        opts.on_tail('-h', '--help', 'Show this message') do
          puts opts
          exit
        end
      end.parse!
    end
  end
end
