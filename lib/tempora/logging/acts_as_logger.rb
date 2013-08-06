module Tempora
  module Logging
    module ActsAsLogger
      extend ActiveSupport::Concern

      def is_logger?
        false
      end

      module ClassMethods
        def is_logger?
          false
        end

        # Sets needed has_many association, includes and extends.
        # @param opts {} is optional
        def acts_as_logger(opts={})
          has_many :logs, as: :logger, class_name: "Tempora::Logging::Log"
          include Tempora::Logging::Base
          include Tempora::Logging::Logger
        end
      end
    end
  end
end