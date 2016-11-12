module TShield
  class Version
    MAJOR = 0
    MINOR = 3
    PATCH = 1
    PRE = 0

    class << self
      def to_s
        [MAJOR, MINOR, PATCH, PRE].compact.join('.')
      end
    end
  end
end

