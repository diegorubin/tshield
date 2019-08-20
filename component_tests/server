#!/usr/bin/env ruby
# frozen_string_literal: true

require 'json'
require 'sinatra'
require 'byebug'

get '/users' do
  [{
    name: 'name'
  }].to_json
end

get '/resources' do
  params.to_json
end

get '/conflicts/path' do
  'vcr'
end

set :port, 9090
