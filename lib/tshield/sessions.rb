# frozen_string_literal: true

require 'tshield/logger'
require 'tshield/counter'
require 'tshield/errors'

module TShield
  # Manage sessions
  #
  # Start and stop session for ip
  module Sessions
    def self.start(ip, name)
      TShield.logger.info("starting session #{name} for ip #{normalize_ip(ip)}")
      sessions[normalize_ip(ip)] = {
        name: name,
        counter: TShield::Counter.new,
        secondary_sessions: []
      }
    end

    def self.stop(ip)
      TShield.logger.info("stoping session for ip #{normalize_ip(ip)}")
      sessions[normalize_ip(ip)] = nil
    end

    def self.current(ip)
      TShield.logger.info("fetching session for ip #{normalize_ip(ip)}")
      sessions[normalize_ip(ip)]
    end

    def self.append(ip, name)
      TShield.logger.info("appeding session #{name} for ip #{normalize_ip(ip)}")

      current_session = sessions[normalize_ip(ip)]
      raise AppendSessionWithoutMainSessionError, "not found main session for #{ip}" unless current_session

      current_session[:secondary_sessions] << name
      current_session
    end

    def self.sessions
      @sessions ||= {}
    end

    def self.normalize_ip(ip)
      ip == '::1' ? '127.0.0.1' : ip
    end
  end
end
