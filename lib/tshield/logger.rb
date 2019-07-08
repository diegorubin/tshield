# frozen_string_literal: true

require 'logger'

# Logger instance for application
module TShield
  def self.logger
    @logger ||= Logger.new(STDOUT)
  end
end
