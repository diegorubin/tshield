# frozen_string_literal: true

# Requests Helpers
class TShieldHelpers
  BASE_URL = 'http://localhost:4567'
  def self.tshield_url(path)
    BASE_URL + path
  end
end
