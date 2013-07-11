module Tempora
  module Logging
    module Loggable
      extend ActiveSupport::Concern

      module ClassMethods
        def acts_as_loggable(opts={})
          has_many :logs, as: :loggable, class_name: Tempora::Logging::Log
          include LoggableMethods
        end

        def is_loggable?
          false
        end
      end

      module LoggableMethods
        def is_loggable?
          true
        end

        def type
          self.class.to_s
        end
      end
    end
  end
end