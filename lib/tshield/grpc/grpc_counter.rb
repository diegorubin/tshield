# frozen_string_literal: true

module TShield
  # Increment counter for sessions requests
  class GrpcCounter
    def initialize
      @requests = {}
    end

    def add(hexdigest)
      requests_to_hexdigest = @requests.fetch(hexdigest, 0)

      requests_to_hexdigest += 1
      @requests[hexdigest] = requests_to_hexdigest
    end

    def current(hexdigest)
      @requests.fetch(hexdigest, 0)
    end

    def to_json(options = {})
      @requests.to_json(options)
    end
  end
end
