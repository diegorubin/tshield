module TShield
  class Version
    MAJOR = 0
    MINOR = 5
    PATCH = 2
    PRE = 0

    class << self
      def to_s
        [MAJOR, MINOR, PATCH, PRE].compact.join('.')
      end
    end
  end
end

