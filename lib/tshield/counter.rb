module TShield
  class Counter

    def initialize
      @requests = {}
    end

    def add(path, method)
      requests_to_path = @requests.fetch(path, {})
      requests_to_method = requests_to_path.fetch(method, 0)

      requests_to_path[method] = requests_to_method += 1
      @requests[path] = requests_to_path
    end

    def current(path, method)
      @requests.fetch(path, {}).fetch(method, 0)
    end

    def to_json(options = {})
      @requests.to_json
    end

  end
end

