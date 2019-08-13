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
      @matched = find_stub
      return unless @matched

      TShield::Response.new(@matched['body'],
                            @matched['headers'],
                            @matched['status'])
    end

    private

    def find_stub
      stubs = self.class.stubs[@path]
      return unless stubs

      filter_stubs(stubs)
    end

    def filter_stubs(stubs)
      result = stubs
               .select { |stub| stub['method'] == @options[:method] }
               .select { |stub| self.class.include_headers(stub['headers'], @options[:headers]) }
      result[0]['response'] unless result.empty?
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

      def include_headers(stub_headers, request_headers)
        request_headers ||= {}
        stub_headers ||= {}
        result = stub_headers.reject { |key, value| request_headers[to_rack_name(key)] == value }
        result.empty? || stub_headers.empty?
      end

      def to_rack_name(key)
        "HTTP_#{key.upcase.gsub('-', '_')}"
      end
    end
  end
end
