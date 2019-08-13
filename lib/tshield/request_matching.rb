# frozen_string_literal: true

require 'tshield/request'

module TShield
  # Class to check request matching
  class RequestMatching
    attr_reader :response

    def initialize(path, options = {})
      super()
      @path = path
      @options = options

      self.class.load_stubs unless self.class.stubs

      match_request
    end

    def match_request; end

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
          @stubs[item['path']] ||= []
          @stubs[item['path']] << item
        end
      end
    end
  end
end
