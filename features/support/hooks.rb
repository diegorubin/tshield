# frozen_string_literal: true

require 'fileutils'

Before do
  # clear requests directory
  FileUtils.rm_rf('./component_tests/requests')
end
