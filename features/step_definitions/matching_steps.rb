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
When('this path {string} is accessed throught tshield {int} times') do |path, number_of_calls|
  @responses = []
  number_of_calls.times.each do |_time|
    @responses << HTTParty.get(TShieldHelpers.tshield_url(path),
                               headers: @headers, query: @query)
  end
end

Then('call number {int} response should be equal {string}') do |call_number, value|
  expect(@responses[call_number - 1].body).to eql(value)
end

Then('response should have header {string} with value {string}') do |key, value|
  expect(@response.headers[key]).to eql(value)
end
