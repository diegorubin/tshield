# frozen_string_literal: true

require 'tshield/matching/filters'
require 'tshield/request'

DEFAULT_SESSION = 'no-session'

module TShield
  # Class to check request matching
  class RequestMatching
    include TShield::Matching::Filters

    attr_reader :matched

    def initialize(path, options = {})
      super()
      @path = path
      @options = options
      @options[:session] ||= DEFAULT_SESSION
      @options[:method] ||= 'GET'

      klass = self.class
      klass.load_stubs unless klass.stubs
    end

    def match_request
      @matched = find_stub(self.class.stubs)
      return unless matched

      TShield::Response.new(self.class.read_body(matched['body']),
                            matched['headers'],
                            matched['status'])
    end

    class << self
      attr_reader :stubs

      def clear_stubs
        @stubs = nil
      end

      def load_stubs
        @stubs = {}
        Dir.glob('matching/**/*.json').each do |entry|
          load_stub(entry)
        end
      end

      def load_stub(file)
        content = JSON.parse File.open(file).read
        content.each do |stub|
          stub_session_name = init_stub_session(stub)

          if stub['stubs']
            load_items(stub['stubs'] || [], stub_session_name)
          else
            load_item(stub, stub_session_name)
          end
        end
      end

      def init_stub_session(stub)
        stub_session_name = stub['session'] || DEFAULT_SESSION
        stubs[stub_session_name] ||= {}
        stub_session_name
      end

      def load_items(items, session_name)
        items.each { |item| load_item(item, session_name) }
      end

      def load_item(item, session_name)
        stubs[session_name][item['path']] ||= []
        stubs[session_name][item['path']] << item
      end

      def read_body(content)
        return content.to_json if content.is_a? Hash

        content
      end
    end
  end
end
