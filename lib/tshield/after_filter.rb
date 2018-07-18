module TShield

  # Example:
  # def filter(response)
  #   response
  # end
  class AfterFilter
    def filter(response)
      raise 'should implement method filter and returns response'
    end
  end
end
