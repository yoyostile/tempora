module Tempora
  module Logging
    module Logger
      extend ActiveSupport::Concern

      module ClassMethods
        def is_logger?
          false
        end

        # Sets needed has_many association, includes and extends.
        # @param opts {} is optional
        def acts_as_logger(opts={})
          has_many :logs, as: :logger, class_name: "Tempora::Logging::Log"
          include LoggerMethods
          extend LoggerClassMethods
        end
      end

      module LoggerClassMethods
        def is_logger?
          true
        end

        # @return [Array] with found loggable associations
        def loggable_assoc
          assoc = []
          self.reflections.values.each do |ref|
            if ref.klass.is_loggable?
              assoc.push ref
            end
          end
          assoc
        end
      end

      module LoggerMethods

        # Creates a new log entry for self and the given loggable
        # @param loggable item to log
        # @param opts {}
        def log(loggable, opts={})
          return false unless loggable.respond_to?(:is_loggable?) && loggable.is_loggable?
          logs.create loggable: loggable, event: "#{loggable.class.to_s}::#{opts[:event]}"
        end

        def ratings
          Tempora.redis.hgetall Tempora::KeyMapper.logger_key self
        end

        def is_logger?
          true
        end

        def is_loggable?
          false
        end

        # Is self associated with loggable?
        # @param loggable
        # @return [Boolean]
        def assoc_with? loggable
          if loggable.is_loggable?
            assoc = loggable.send(loggable.class.logger_assoc.select{
              |a| a.klass == self.class
            }.first.plural_name).find self rescue nil
          end
          assoc.present?
        end

        # @param limit [Integer]
        # @return [Array] List with recommended items
        def recommendation_list limit = 10
          Tempora::Recommender::Core.recommendation_list self, limit
        end

        # @param loggable_class your loggable model
        # @return [Array] associated items
        def association_list loggable_class
          if loggable_class.is_loggable?
            assoc = self.send(self.class.loggable_assoc.select{
              |a| a.klass == loggable_class
            }.first.plural_name)
          end
        end
      end
    end
  end
end