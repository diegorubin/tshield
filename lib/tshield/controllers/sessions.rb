require 'sinatra/base'

require 'tshield/configuration'
require 'tshield/sessions'

module TShield
  module Controllers
    module Sessions
      def self.registered(app)

        app.get TShield::Configuration.singleton.session_path do
          TShield::Sessions.current(request.ip).to_json
        end

        app.post TShield::Configuration.singleton.session_path do
          TShield::Sessions.start(request.ip, params[:name]).to_json
        end

        app.delete TShield::Configuration.singleton.session_path do
          TShield::Sessions.stop(request.ip).to_json
        end

      end
    end
  end
end

