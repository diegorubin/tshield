module TShield
  class Response
    attr_accessor :body, :headers, :original

    def initialize(body, headers)
      @body = body
      @headers = headers
    end
  end
end
