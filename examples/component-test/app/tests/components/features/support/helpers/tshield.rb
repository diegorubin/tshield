# frozen_string_literal: true

require 'httparty'

module Helpers
  module TShield
    def start_session(name)
      HTTParty.post $env['tshield']['sessions_url'], query: { name: name }
    end

    def stop_session
      HTTParty.delete $env['tshield']['sessions_url']
    end
  end
end
