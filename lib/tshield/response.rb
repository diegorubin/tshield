# frozen_string_literal: true

module TShield
  # Response Object
  class Response
    attr_accessor :original
    attr_reader :body, :headers, :status

    def initialize(body, headers, status)
      @body = body
      @headers = headers
      @status = status
    end
  end
end
