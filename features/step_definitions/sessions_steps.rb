# frozen_string_literal: true

Given('in session {string}') do |session|
  TShieldHelpers.start_session(session)
end

When('start session {string}') do |session|
  TShieldHelpers.start_session(session)
end

When('append session {string}') do |session|
  TShieldHelpers.append_session(session)
end
