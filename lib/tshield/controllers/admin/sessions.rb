# frozen_string_literal: true

require 'sinatra/base'

require 'tshield/configuration'

module TShield
  module Controllers
    module Admin
      module Sessions
        def self.registered(app)
          app.helpers do
            def admin_session_request_path(session)
              "#{TShield::Configuration.singleton.admin_session_path}/#{session}/requests"
            end
          end

          app.get TShield::Configuration.singleton.admin_session_path do
            @sessions = get_tshield_sessions
            haml :'admin/sessions/index', layout: :'layout/base'
          end
        end

        module Helpers
          protected

          def get_tshield_sessions
            entries = Dir.entries('requests').delete_if { |s| s =~ /^\.\.?$/ }
            entries.delete_if { |s| domains.include?(s) }
          end

          def domains
            @domains ||= TShield::Configuration.singleton.domains
                                               .keys.collect { |d| d.gsub(%r{^.*?://}, '') }
          end
        end
      end
    end
  end
end
