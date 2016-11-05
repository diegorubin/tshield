require 'sinatra/base'

require 'tshield/configuration'

module TShield
  module Controllers
    module Sessions
      def self.registered(app)
        app.post TShield::Configuration.singleton.session_path do
          puts "\n\n\nhello\n\n\n"
        end
      end
    end
  end
end

