# frozen_string_literal: true

require 'tshield/logger'
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

      @matched = current_response

      sleep matched['delay'] || 0
      TShield::Response.new(self.class.read_body(matched['body']),
                            matched['headers'],
                            matched['status'])
    end

    def current_response
      if matched.is_a? Array
        index = @options[:call] % matched.size
        return matched[index]
      end

      matched
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
        content = read_stub_file(file)
        content.each do |stub|
          next unless valid_stub?(file, stub)

          load_valid_stub(stub)
        end
      end

      def read_stub_file(file)
        JSON.parse File.open(file).read
      rescue StandardError
        TShield.logger.error "error in loading matching file #{file}"
        []
      end

      def valid_stub?(file, stub)
        is_valid = stub.is_a?(Hash) && mandatory_attributes?(stub)
        TShield.logger.info "loading matching file #{file}" if is_valid
        is_valid
      end

      def mandatory_attributes?(stub)
        (stub['method'] && stub['path'] && stub['response']) || (stub['session'] && stub['stubs'])
      end

      def load_valid_stub(stub)
        stub_session_name = init_stub_session(stub)

        if stub['stubs']
          load_items(stub['stubs'] || [], stub_session_name)
        else
          load_item(stub, stub_session_name)
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
        return read_file_content(content) if content =~ %r{^FILE://}

        content
      end

      def read_file_content(content)
        File.open(File.join('matching', content.gsub('FILE://', '')), 'r').read
      end
    end
  end
end
