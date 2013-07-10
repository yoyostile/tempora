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
          logs.create loggable: loggable, weight: opts[:weight], event: opts[:event]
        end

        def average_weight(loggable)
          weights = logs.where('loggable_id = ? AND loggable_type = ?', loggable.id, loggable.type).average(:weight)
        end

        def is_logger?
          true
        end
      end
    end
  end
end