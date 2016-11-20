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

    set :public_dir, File.join(File.dirname(__FILE__), 'assets')
    set :views, File.join(File.dirname(__FILE__), 'views')

    register TShield::Controllers::Admin::Sessions
    register TShield::Controllers::Admin::Requests

    register TShield::Controllers::Sessions
    register TShield::Controllers::Requests

  end
end

