# frozen_string_literal: true

require 'tshield/request'

module TShield
  # Class to check request matching
  class RequestMatching
    def initialize(path, options = {})
      super()
      @path = path
      @options = options

      klass = self.class
      klass.load_stubs unless klass.stubs
    end

    def match_request
      matched = find_stub(@path, @options)
      return unless matched

      TShield::Response.new(matched['body'],
                            matched['headers'],
                            matched['status'])
    end

    private

    def find_stub(path, options)
      stubs = self.class.stubs[path]
      return unless stubs

      stubs
        .select { |stub| stub['method'] == options[:method] }[0]['response']
    end

    class << self
      attr_reader :stubs

      def load_stubs
        @stubs = {}
        Dir.glob('matching/**/*.json').each do |entry|
          load_stub(entry)
        end
      end

      def load_stub(file)
        content = JSON.parse File.open(file).read
        content.each do |item|
          stubs[item['path']] ||= []
          stubs[item['path']] << item
        end
      end
    end
  end
end
