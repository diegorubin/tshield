# frozen_string_literal: true

Given("a {string} session") do |session|
  start_session(session)
end

When("visit home page") do
  @page = HomePage.new
  @page.load
end

And("do search with {string}") do |search|
  @page.do_search(search)
end


Then("show result") do |table|
  expect(@page.card_result_name).to have_text(table.hashes[0][:name])
  expect(@page.card_result_comic).to have_text(table.hashes[0][:first_comic])
  expect(@page.card_result_img[:src]).to have_text(table.hashes[0][:gif_url])
end


Then("show error") do |table|
  expect(@page.card_error_title).to have_text(table.hashes[0][:title])
  expect(@page.card_error_msg).to have_text(table.hashes[0][:message])
end
