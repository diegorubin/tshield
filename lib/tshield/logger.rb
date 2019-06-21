# frozen_string_literal: true

require 'logger'

module TShield
  def self.logger
    @logger ||= Logger.new(STDOUT)
  end
end
