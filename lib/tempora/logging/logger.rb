module Tempora
  module Logging
    module Logger
      extend ActiveSupport::Concern

      module ClassMethods
        def acts_as_logger(opts={})
          has_many :logs, as: :logger, class_name: Tempora::Logging::Log
          include LoggerMethods
        end

        def is_logger?
          false
        end
      end

      module LoggerMethods
        def log(loggable, opts={})
          return false unless loggable.respond_to?(:is_loggable?) && loggable.is_loggable?
          logs.create loggable: loggable, event: opts[:event]
        end

        def is_logger?
          true
        end
      end
    end
  end
end