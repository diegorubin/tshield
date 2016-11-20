module TShield
  class Version
    MAJOR = 0
    MINOR = 4
    PATCH = 0
    PRE = 1

    class << self
      def to_s
        [MAJOR, MINOR, PATCH, PRE].compact.join('.')
      end
    end
  end
end

