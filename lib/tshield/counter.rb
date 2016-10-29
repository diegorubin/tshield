module TShield
  class Counter

    attr_accessor :count

    def self.singleton
      @@counter ||= init
    end

    private
    def self.init
      Counter.new
    end

  end
end

