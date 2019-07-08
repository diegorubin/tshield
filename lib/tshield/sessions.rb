# frozen_string_literal: true

require 'byebug'
require 'tshield/counter'

module TShield
  # Manage sessions
  #
  # Start and stop session for ip
  module Sessions
    def self.start(ip, name)
      sessions[normalize_ip(ip)] = { name: name, counter: TShield::Counter.new }
    end

    def self.stop(ip)
      sessions[normalize_ip(ip)] = nil
    end

    def self.current(ip)
      sessions[normalize_ip(ip)]
    end

    def self.sessions
      @sessions ||= {}
    end

    def self.normalize_ip(ip)
      ip == '::1' ? '127.0.0.1' : ip
    end
  end
end
