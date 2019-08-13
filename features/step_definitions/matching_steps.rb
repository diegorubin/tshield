# frozen_string_literal: true

Given('a file to describe {string} path') do |path|
  @path = path
end

Given('a file to describe {string} path only for method {string}') do |path, method|
  @path = path
  @method = method
end

When('this path {string} is accessed throught tshield via {string}') do |path, method|
  @response = HTTParty.send(method, TShieldHelpers.tshield_url(path))
end
