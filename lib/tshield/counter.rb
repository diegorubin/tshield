# frozen_string_literal: true

module TShield
  # Increment counter for sessions requests
  class Counter
    def initialize
      @requests = {}
    end

    def add(callid, method)
      requests_to_callid = @requests.fetch(callid, {})
      requests_to_method = requests_to_callid.fetch(method, 0)

      requests_to_callid[method] = requests_to_method + 1
      @requests[callid] = requests_to_callid
    end

    def current(callid, method)
      @requests.fetch(callid, {}).fetch(method, 0)
    end

    def to_json(options = {})
      @requests.to_json(options)
    end
  end
end
