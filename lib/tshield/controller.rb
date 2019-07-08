# frozen_string_literal: true

require 'sinatra'

require 'tshield/logger'

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
          load_action(app, class_method, options)
        end
      end

      def load_action(app, class_method, options)
        msg = "== registering #{options[:path]}"
        msg << " for methods #{options[:methods].join(',')}"
        msg << " with action #{class_method}"

        TShield.logger.infod(msg)
        options[:methods].each do |method|
          app.send(method, options[:path]) do
            send(class_method, params, request)
          end
        end
      end
    end
  end
end
