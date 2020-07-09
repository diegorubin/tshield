# frozen_string_literal: true

require 'tshield/counter'

module TShield
  # Manage sessions
  #
  # Start and stop session for ip
  module Sessions
    def self.start(ip, name)
      TShield.logger.info("starting session #{name} for ip #{normalize_ip(ip)}")
      sessions[normalize_ip(ip)] = { name: name, counter: TShield::Counter.new }
    end

    def self.stop(ip)
      TShield.logger.info("stoping session for ip #{normalize_ip(ip)}")
      sessions[normalize_ip(ip)] = nil
    end

    def self.current(ip)
      TShield.logger.info("fetching session for ip #{normalize_ip(ip)}")
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
