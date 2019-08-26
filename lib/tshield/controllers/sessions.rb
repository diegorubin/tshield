# frozen_string_literal: true

require 'sinatra/base'

require 'tshield/configuration'
require 'tshield/sessions'

module TShield
  module Controllers
    # Actions to handle sessions
    module Sessions
      def self.registered(app)
        session_path = TShield::Configuration.singleton.session_path
        ip = request.ip
        register_get(app, session_path, ip)
        register_post(app, session_path, ip, params)
        register_delete(app, session_path, ip)
      end

      def self.register_get(app, session_path, ip)
        app.get session_path do
          TShield::Sessions.current(ip).to_json
        end
      end

      def self.register_post(app, session_path, params, ip)
        app.post session_path do
          TShield::Sessions.start(ip, params[:name]).to_json
        end
      end

      def self.register_delete(app, session_path, ip)
        app.delete session_path do
          TShield::Sessions.stop(ip).to_json
        end
      end
    end
  end
end
