# frozen_string_literal: true

# Requests Helpers
class TShieldHelpers
  BASE_URL = 'http://localhost:4567'

  def self.tshield_url(path)
    BASE_URL + path
  end

  def self.start_session(session)
    HTTParty.post(TShieldHelpers.tshield_url('/sessions'), query: { name: session })
  end

  def self.append_session(session)
    HTTParty.post(TShieldHelpers.tshield_url('/sessions/append'), query: { name: session })
  end

  def self.stop_session
    HTTParty.delete(TShieldHelpers.tshield_url('/sessions'))
  end
end
