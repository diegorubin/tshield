require 'sinatra/base'
require 'byebug'

require 'tshield/configuration'

module TShield
  module Controllers
    module Admin
      module Requests
        def self.registered(app)
          configuration = TShield::Configuration.singleton

          app.helpers do
            def admin_domain_requests_path(session, domain)
              "#{configuration.admin_session_path}/#{session}/requests/#{domain}"
            end
          end

          app.get "#{configuration.admin_session_path}/:session/requests" do
            @session = params[:session]
            @domains = get_domains_by_session(@session)
            haml :'admin/requests/index', layout: :'layout/base'
          end

          app.get "#{configuration.admin_session_path}/:session/requests/:domain" do
            @session = params[:session]
            @domain = params[:domain]
            @requests = get_requests(@session, @domain)
            haml :'admin/requests/show', layout: :'layout/base'
          end
        end

        module Helpers
          def get_domains_by_session(session)
            Dir.entries("requests/#{session}").delete_if { |entry| entry =~ /^\.\.?$/ }
          end

          def get_requests(session, domain)
            requests = []
            path = File.join("requests", session, domain)
            Dir.entries(path).each do |url_path|
              next if url_path =~ /^\.\.?$/
              Dir.entries(File.join(path, url_path)).each do |method|
                next if method =~ /^\.\.?$/
                Dir.entries(File.join(path, url_path, method)).each do |request|
                  next if request =~ /^\.\.?$/
                  raw = File.open(File.join(path, url_path, method, request)).read
                  content = JSON.parse(raw)
                  content['method'] = method
                  content['title'] = url_path
                  content['position'] = request =~ /(\d+).json/ && $1
                  requests << content
                end
              end
            end
            requests
          end
        end
      end
    end
  end
end
