  module Tempora
  module Logging
    module Loggable
      extend ActiveSupport::Concern

      module ClassMethods
        def is_loggable?
          true
        end

        # @return [Array] with found logger associations
        def logger_assoc
          self.reflections.values.select{ |r| r.klass.is_logger? }
        end
      end


      def is_loggable?
        true
      end

      # Is self associated with logger?
      # @param logger
      # @return [Boolean]
      def assoc_with? logger
        if logger.is_logger?
          assoc = logger.send(logger.class.loggable_assoc.select{
            |a| a.klass == self.class
          }.first.plural_name).exists? self rescue nil
        end
        assoc.present?
      end
    end
  end
end