# frozen_string_literal: true

module TShield
  module Controllers
    module Helpers
      # Session Helpers
      module SessionHelpers
        def self.current_session_name(request)
          session = TShield::Sessions.current(request.ip)
          session ? session[:name] : 'no-session'
        end
      end
    end
  end
end
