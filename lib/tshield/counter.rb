module TShield
  class Counter

    attr_reader :sessions

    def initialize
      @sessions = {}
    end

    def add(from, key)
      requests = @sessions.fetch(from, {})
      requests[key] ||= 0
      requests[key] += 1
      @sessions[from] = requests
    end

    def self.singleton
      @@counter ||= init
    end

    private
    def self.init
      counter = Counter.new
      counter
    end

  end
end

