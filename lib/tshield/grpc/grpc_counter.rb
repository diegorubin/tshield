# frozen_string_literal: true

module TShield
  # Increment counter for sessions requests
  class GrpcCounter
    def initialize
      @requests = {}
    end

    def add(hexdigest)
      count = @requests.fetch(hexdigest, 0)
      count += 1
      @requests[hexdigest] = count
    end

    def current(hexdigest)
      @requests.fetch(hexdigest, 0)
    end

    def to_json(options = {})
      @requests.to_json(options)
    end
  end
end
