# frozen_string_literal: true

Given('a valid api {string}') do |path|
  @path = path
end

Given('a valid content saved in {string} with content {string}') do |directory, content|
  FileUtils.mkdir_p File.join('./component_tests/requests/components', directory, 'get')
  file = File
         .open(File.join('./component_tests/requests/components', directory, 'get/0.content'), 'w')
  file.print content
  file.close

  file = File.open(File.join('./component_tests/requests/components', directory, 'get/0.json'), 'w')
  file.puts "{\n  \"status\": 200,\n  \"headers\": {\n  }\n}"
  file.close
end

Given('saved vcr session called {string}') do |session_name|
  VCRHelpers.create_saved_session(session_name)
end

When('this api is accessed throught tshield') do
  @time = Time.now
  HTTParty.get(TShieldHelpers.tshield_url(@path))
end

When('this api is accessed throught tshield with param {string} and value {string}') do |key, value|
  @response = HTTParty.get(TShieldHelpers.tshield_url(@path), query: { key => value })
end

When('this path {string} is accessed throught tshield') do |path|
  @time = Time.now
  @response = HTTParty.get(TShieldHelpers.tshield_url(path))
end

Then('response should be saved in {string}') do |destiny|
  content = JSON.parse(RequestsHelpers.content_for(destiny))
  expect(content).to eq(UsersHelpers.users_content)
end

Then('response should be saved in {string} in session {string}') do |destiny, session|
  content = JSON.parse(RequestsHelpers.content_for_in_session(destiny, session))
  expect(content).to eq(UsersHelpers.users_content)
end

Then('response should be saved in directory {string}') do |directory|
  Dir.entries('./component_tests/requests/components').each do |entry|
    next if entry !~ /resources/

    expect(entry).to eql(directory)
  end
end

Then('response should delay {string} than {int} seconds') do |operation, content|
  @time = Time.now - @time
  if operation == 'more'
    expect(@time).to be >= content
  else
    expect(@time).to be < content
  end
end

Then('response should be equal {string}') do |content|
  expect(@response.body).to eql(content.gsub('\\n', "\n"))
end

Then('should get response saved into session {string}') do |session|
  expect(@response.body.strip).to eql(VCRHelpers.response_for(session))
end
