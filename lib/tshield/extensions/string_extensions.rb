# frozen_string_literal: true

# String Extensions
module StringExtensions
  def to_rack_name
    "HTTP_#{upcase.tr('-', '_')}"
  end

  def underscore
    gsub(/::/, '/')
      .gsub(/([A-Z]+)([A-Z][a-z])/, '\1_\2')
      .gsub(/([a-z\d])([A-Z])/, '\1_\2')
      .tr('-', '_')
      .downcase
  end
end

String.include StringExtensions
