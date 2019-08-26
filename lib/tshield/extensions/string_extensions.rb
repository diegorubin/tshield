# frozen_string_literal: true

# String Extensions
module StringExtensions
  def to_rack_name
    "HTTP_#{upcase.gsub('-', '_')}"
  end
end

String.include StringExtensions
