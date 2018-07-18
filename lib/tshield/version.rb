module TShield
  class Version
    MAJOR = 0
    MINOR = 6
    PATCH = 1
    PRE = 1

    class << self
      def to_s
        [MAJOR, MINOR, PATCH, PRE].compact.join('.')
      end
    end
  end
end

