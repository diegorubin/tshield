# frozen_string_literal: true

# Requests Helpers
class RequestsHelpers
  def self.content_for(destiny)
    File.open("./component_tests/requests/components/#{destiny}").read
  end

  def self.content_for_in_session(destiny, session)
    File.open("./component_tests/requests/#{session}/components/#{destiny}").read
  end
end
