# frozen_string_literal: true

require 'sinatra'

module TShield
  # TShield Controller
  module Controller
    def self.included(base)
      base.extend ClassMethods
    end

    # Implementation of actions
    module ClassMethods
      def action(class_method, options)
        @actions = {} unless defined? @actions
        @actions[class_method] = options
      end

      def registered(app)
        @actions.each do |class_method, options|
          puts "== registering #{options[:path]} for methods #{options[:methods].join(',')} with action #{class_method}"
          options[:methods].each do |method|
            app.send(method, options[:path]) { send(class_method, params, request) }
          end
        end
      end
    end
  end
end
