# frozen_string_literal: true

require 'socket'

module TShield
  class SimpleTCPServer
    def initialize
      @running = true
    end

    def on_connect(_client)
      raise 'should implement method on_connect'
    end

    def close
      @running = false
    end

    def listen(port)
      puts "listening #{port}"
      @server = TCPServer.new(port)
      while @running
        client = @server.accept
        on_connect(client)
      end
    end
  end
end
