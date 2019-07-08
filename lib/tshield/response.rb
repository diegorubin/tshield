# frozen_string_literal: true

module TShield
  class Response
    attr_accessor :body, :headers, :status, :original

    def initialize(body, headers, status)
      @body = body
      @headers = headers
      @status = status
    end
  end
end
