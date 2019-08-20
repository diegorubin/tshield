# frozen_string_literal: true

Given('a file to describe {string} path') do |path|
  @path = path
end

Given('a file to describe {string} path only for method {string}') do |path, method|
  @path = path
  @method = method
end

Given('header {string} with value {string}') do |key, value|
  @headers ||= {}
  @headers[key] = value
end

Given('query {string} with value {string}') do |key, value|
  @query ||= {}
  @query[key] = value
end

When('this path {string} is accessed throught tshield via {string}') do |path, method|
  @response = HTTParty.send(method, TShieldHelpers.tshield_url(path),
                            headers: @headers, query: @query)
end
