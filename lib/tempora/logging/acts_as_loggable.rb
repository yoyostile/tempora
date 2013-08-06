module Tempora
  module Logging
    module ActsAsLoggable
      extend ActiveSupport::Concern

      def is_loggable?
        false
      end

      module ClassMethods
        def is_loggable?
          false
        end

        # Sets needed has_many association, includes and extends.
        # @param opts {} is optional
        def acts_as_loggable(opts={})
          has_many :logs, as: :loggable, class_name: "Tempora::Logging::Log"
          include Tempora::Logging::Loggable
        end
      end
    end
  end
end