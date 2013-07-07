module Tempora
  module Logger
    def self.include(base)
      base.extend ClassMethods
    end

    module ClassMethods
      def acts_as_logger(opts={})
        has_many :logs, as: :logger
      end

      def is_logger?
        false
      end
    end

    module InstanceMethods
      def log(loggable, opts={})
        return false unless loggable.respond_to?(:is_loggable?) && loggable.is_loggable?

        
      end

      def is_logger?
        self.class.is_logger?
      end
    end
  end
end
