module Tempora
  module Logging
    module Loggable
      extend ActiveSupport::Concern

      included do
      end

      module ClassMethods
        def acts_as_loggable(opts={})
          has_many :logs, as: :loggable, class_name: Tempora::Logging::Log
        end

        def is_loggable?
          false
        end
      end

      module InstanceMethods
        def is_loggable?
          true
        end

        def type
          self.class.to_s
        end

        def average_weight
          weights = logs.pluck(:weight)
          weights.inject{ |sum, f| sum + f }.to_f / weights.size
        end
      end
    end
  end
end

ActiveRecord::Base.send :include, Tempora::Logging::Loggable