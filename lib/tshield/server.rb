# frozen_string_literal: true

require 'sinatra'
require 'haml'

require 'tshield/controllers/requests'
require 'tshield/controllers/sessions'

require 'tshield/controllers/admin/requests'
require 'tshield/controllers/admin/sessions'

module TShield
  class Server < Sinatra::Base
    include TShield::Controllers::Requests::Helpers
    include TShield::Controllers::Admin::Sessions::Helpers
    include TShield::Controllers::Admin::Requests::Helpers

    if File.exist?('controllers')
      Dir.entries('controllers').each do |entry|
        next if entry =~ /^\.\.?$/

        entry.gsub!('.rb', '')
        require File.join('.', 'controllers', entry)
        controller_name = entry.split('_').collect(&:capitalize).join
        include Module.const_get("#{controller_name}::Actions")
        register Module.const_get(controller_name)
      end
    end

    set :protection, except: [:json_csrf]
    set :public_dir, File.join(File.dirname(__FILE__), 'assets')
    set :views, File.join(File.dirname(__FILE__), 'views')
    set :bind, '0.0.0.0'

    register TShield::Controllers::Admin::Sessions
    register TShield::Controllers::Admin::Requests

    register TShield::Controllers::Sessions
    register TShield::Controllers::Requests
  end
end
