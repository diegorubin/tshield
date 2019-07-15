# frozen_string_literal: true

BASE_URL = 'http://localhost:4567'

# Requests Helpers
class TShieldHelpers
  def self.tshield_url(path)
    BASE_URL + path
  end
end
