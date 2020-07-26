# frozen_string_literal: true

module TShield
  module Matching
    # Filters used in request matching
    module Filters
      def find_stub(stubs)
        result = filter_stubs(stubs[@options[:session]] || {})
        return result if result

        find_in_secundary_sessions(stubs, @options[:secundary_sessions] || [])
      end

      def find_in_secundary_sessions(stubs, sessions)
        sessions.each do |session|
          result = filter_stubs(stubs[session] || {})
          return result if result
        end
        filter_stubs(stubs[DEFAULT_SESSION] || {}) unless @options[:session] == DEFAULT_SESSION
      end

      def filter_by_method(stubs)
        stubs.select { |stub| stub['method'] == @options[:method] }
      end

      def filter_by_headers(stubs)
        stubs.select { |stub| Filters.include_headers(stub['headers'], @options[:headers]) }
      end

      def filter_by_query(stubs)
        stubs.select { |stub| Filters.include_query(stub['query'], @options[:raw_query] || '') }
      end

      def filter_by_path(stubs)
        stubs.each do |key, value|
          return value if @path =~ /^#{key}$/
        end
      end

      def filter_stubs(stubs)
        result = filter_by_query(filter_by_headers(filter_by_method(filter_by_path(stubs))))
        result[0]['response'] unless result.empty?
      end

      def self.include_headers(stub_headers, request_headers)
        request_headers ||= {}
        stub_headers ||= {}
        result = stub_headers.reject { |key, value| request_headers[key.to_rack_name] == value }
        result.empty? || stub_headers.empty?
      end

      def self.include_query(stub_query, raw_query)
        request_query = Filters.build_query_hash(raw_query)
        stub_query ||= {}
        result = stub_query.reject { |key, value| request_query[key] == value.to_s }
        result.empty? || stub_query.empty?
      end

      def self.build_query_hash(raw_query)
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
