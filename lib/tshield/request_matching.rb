# frozen_string_literal: true

require 'tshield/request'

DEFAULT_SESSION = 'no-session'

module TShield
  # Class to check request matching
  class RequestMatching
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
      @matched = find_stub
      return unless matched

      TShield::Response.new(matched['body'],
                            matched['headers'],
                            matched['status'])
    end

    private

    def find_stub
      stubs = self.class.stubs
      result = filter_stubs(stubs[@options[:session]])
      return result if result

      filter_stubs(stubs[DEFAULT_SESSION]) unless @options[:session] == DEFAULT_SESSION
    end

    def filter_by_method(stubs)
      stubs.select { |stub| stub['method'] == @options[:method] }
    end

    def filter_by_headers(stubs)
      stubs.select { |stub| self.class.include_headers(stub['headers'], @options[:headers]) }
    end

    def filter_by_query(stubs)
      stubs.select { |stub| self.class.include_query(stub['query'], @options[:raw_query] || '') }
    end

    def filter_stubs(stubs)
      result = filter_by_query(filter_by_headers(filter_by_method(stubs[@path] || [])))
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

      def include_headers(stub_headers, request_headers)
        request_headers ||= {}
        stub_headers ||= {}
        result = stub_headers.reject { |key, value| request_headers[key.to_rack_name] == value }
        result.empty? || stub_headers.empty?
      end

      def include_query(stub_query, raw_query)
        request_query = build_query_hash(raw_query)
        stub_query ||= {}
        result = stub_query.reject { |key, value| request_query[key] == value.to_s }
        result.empty? || stub_query.empty?
      end

      def build_query_hash(raw_query)
        params = {}
        raw_query.split('&').each do |query|
          key, value = query.split('=')
          params[key] = value
        end

        params
      end
    end
  end
end
