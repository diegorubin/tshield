# frozen_string_literal: true

module TShield
  module Controllers
    module Helpers
      # Session Helpers
      module SessionHelpers
        def self.current_session_name(request)
          session = TShield::Sessions.current(request.ip)
          session[:name] if session
        end

        def self.current_session_call(request, path, method)
          session = TShield::Sessions.current(request.ip)
          session ? session[:counter].current(path, method) : 0
        end

        def self.update_session_call(request, path, method)
          session = TShield::Sessions.current(request.ip)
          session[:counter].add(path, method) if session
        end
      end
    end
  end
end
