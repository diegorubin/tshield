# frozen_string_literal: true

require 'sinatra/base'

require 'tshield/configuration'
require 'tshield/sessions'

module TShield
  module Controllers
    # Actions to handle sessions
    module Sessions
      def self.registered(app)
        session_path = TShield::Configuration.singleton.read_session_path
        register_get(app, session_path)
        register_post(app, session_path)
        register_delete(app, session_path)
      end

      def self.register_get(app, session_path)
        app.get session_path do
          TShield::Sessions.current(request.ip).to_json
        end
      end

      def self.register_post(app, session_path)
        app.post "#{session_path}/append" do
          TShield::Sessions.append(request.ip, params[:name]).to_json
        end
        app.post session_path do
          TShield::Sessions.start(request.ip, params[:name]).to_json
        end
      end

      def self.register_delete(app, session_path)
        app.delete session_path do
          TShield::Sessions.stop(request.ip).to_json
        end
      end
    end
  end
end
