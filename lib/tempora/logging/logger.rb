module Tempora
  module Logging
    module Logger
      extend ActiveSupport::Concern

      included do
      end

      module ClassMethods
        def acts_as_logger(opts={})
          has_many :logs, as: :logger, class_name: Tempora::Logging::Log
        end

        def is_logger?
          false
        end
      end

      module InstanceMethods
        def log(loggable, opts={})
          return false unless loggable.respond_to?(:is_loggable?) && loggable.is_loggable?
          logs.create(loggable: loggable)
        end

        def is_logger?
          true
        end
      end
    end
  end
end

ActiveRecord::Base.send :include, Tempora::Logging::Logger