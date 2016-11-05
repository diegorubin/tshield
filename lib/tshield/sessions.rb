require 'byebug'
require 'tshield/counter'

module TShield
  module Sessions
    def self.start(ip, name)
      sessions[ip] = {name: name, counter: TShield::Counter.new}
    end

    def self.stop(ip)
      sessions[ip] = nil
    end

    def self.current(ip)
      sessions[ip]
    end

    protected 
    def self.sessions
      @sessions ||= {}
    end
  end
end

