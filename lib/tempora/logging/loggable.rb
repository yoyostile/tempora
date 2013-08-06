  module Tempora
  module Logging
    module Loggable
      extend ActiveSupport::Concern

      module ClassMethods
        def is_loggable?
          true
        end

        # @return [Array] with found logger associations
        def tempora_assoc
          self.reflections.values.select{ |r| r.klass.is_logger? }
        end
      end


      def is_loggable?
        true
      end

      # Is self associated with logger?
      # @param logger
      # @return [Boolean]
      def assoc_with? obj
        obj.is_logger? && is_tempora_assoc?(obj).present?
      end
    end
  end
end