# frozen_string_literal: true

module TShield
  # Example:
  # def filter(method, url, options)
  #   [method, url, options]
  # end
  class BeforeFilter
    def filter(_method, _url, _options)
      raise 'should implement method filter and returns method, url, options'
    end
  end
end
