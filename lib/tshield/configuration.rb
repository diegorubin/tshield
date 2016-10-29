module TShield
  class Configuration

    attr_accessor :domains

    def singleton
      @@configuration ||= load_configuration
    end

    private
    def load_configuration
    end

  end
end

