require 'sinatra'

require 'tshield/controllers/requests'
require 'tshield/controllers/sessions'

module TShield
  class Server < Sinatra::Base

    include TShield::Controllers::Requests::Helpers

    register TShield::Controllers::Sessions
    register TShield::Controllers::Requests

  end
end


