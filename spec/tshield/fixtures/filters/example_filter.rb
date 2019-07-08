# frozen_string_literal: true

require 'tshield/after_filter'

class ExampleFilter < TShield::AfterFilter
  def filter(response)
    response
  end
end
