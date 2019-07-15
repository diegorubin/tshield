# frozen_string_literal: true

require 'fileutils'

require 'byebug'
Before do
  # clear requests directory
  FileUtils.rm_rf('./component_tests/requests')
end
