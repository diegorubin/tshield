# frozen_string_literal: false

require 'sinatra'
require 'sinatra/cross_origin'

require 'tshield/options'
require 'tshield/controllers/requests'
require 'tshield/controllers/sessions'

module TShield
  # Base of TShield Server
  class Server < Sinatra::Base
    include TShield::Controllers::Requests::Helpers

    set :protection, except: [:json_csrf]
    set :public_dir, File.join(File.dirname(__FILE__), 'assets')
    set :views, File.join(File.dirname(__FILE__), 'views')
    set :bind, '0.0.0.0'
    set :port, TShield::Options.instance.port
    set :server, :puma

    configure do
      enable :cross_origin
    end

    before do
      response.headers['Access-Control-Allow-Origin'] = '*'
    end

    options '*' do
      response.headers['Allow'] = 'GET, PUT, POST, DELETE, OPTIONS'
      response.headers['Access-Control-Allow-Headers'] = 'Authorization, Content-Type,
                                                        Accept, X-User-Email, X-Auth-Token'
      response.headers['Access-Control-Allow-Origin'] = '*'
      200
    end

    def self.register_resources
      load_controllers
      register TShield::Controllers::Sessions
      register TShield::Controllers::Requests
    end

    def self.load_controllers
      return unless File.exist?('controllers')

      Dir.entries('controllers').each do |entry|
        next if entry =~ /^\.\.?$/

        entry.gsub!('.rb', '')
        require File.join('.', 'controllers', entry)
        controller_name = entry.split('_').collect(&:capitalize).join
        include Module.const_get("#{controller_name}::Actions")
        register Module.const_get(controller_name)
      end
    end

    def self.run!
      register_resources
      require 'byebug'
      super
    end
  end
end
