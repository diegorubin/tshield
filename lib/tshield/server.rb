# frozen_string_literal: false

require 'sinatra'
require 'haml'

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

    def self.register_resources
      load_controllers
      register TShield::Controllers::Sessions
      register TShield::Controllers::Requests
    end

    def self.load_controllers
      return unless File.exist?('controllers')

      Dir.entries('controllers').each do |entry|
        require 'byebug'
        debugger
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
      super.run!
    end
  end
end
