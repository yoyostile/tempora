  module Tempora
  module Logging
    module Loggable
      extend ActiveSupport::Concern

      module ClassMethods
        def is_loggable?
          false
        end

        # Sets needed has_many association, includes and extends.
        # @param opts {} is optional
        def acts_as_loggable(opts={})
          has_many :logs, as: :loggable, class_name: "Tempora::Logging::Log"
          include LoggableMethods
          extend LoggableClassMethods
        end
      end

      module LoggableClassMethods
        def is_loggable?
          true
        end

        # @return [Array] with found logger associations
        def logger_assoc
          assoc = []
          self.reflections.values.each do |ref|
            if ref.klass.is_logger?
              assoc.push ref
            end
          end
          assoc
        end
      end


      module LoggableMethods
        def is_loggable?
          true
        end

        def is_logger?
          false
        end

        def type
          self.class.to_s
        end

        # Is self associated with logger?
        # @param logger
        # @return [Boolean]
        def assoc_with? logger
          if logger.is_logger?
            assoc = logger.send(logger.class.loggable_assoc.select{
              |a| a.klass == self.class
            }.first.plural_name).find self rescue nil
          end
          assoc.present?
        end
      end
    end
  end
end