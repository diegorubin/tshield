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

When('this api is accessed throught tshield') do
  HTTParty.get(TShieldHelpers.tshield_url(@path))
end

When('this path {string} is accessed throught tshield') do |path|
  @response = HTTParty.get(TShieldHelpers.tshield_url(path))
end

Then('response should be saved in {string}') do |destiny|
  content = JSON.parse(RequestsHelpers.content_for(destiny))
  expect(content).to eq(UsersHelpers.users_content)
end

Then('response should be saved in directory {string}') do |directory|
  Dir.entries('./component_tests/requests/components').each do |entry|
    next if entry !~ /resources/

    expect(entry).to eql(directory)
  end
end

Then('response should be equal {string}') do |content|
  expect(@response.body).to eql(content)
end
