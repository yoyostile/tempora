module Tempora
  module Logging
    module Logger
      extend ActiveSupport::Concern

      module ClassMethods
        def is_logger?
          true
        end

        # @return [Array] with found loggable associations
        def tempora_assoc
          self.reflections.values.select{ |r| r.klass.is_loggable? }
        end

      end


      # Creates a new log entry for self and the given loggable
      # @param loggable item to log
      # @param opts {}
      def log(loggable, opts={})
        return false unless loggable.is_loggable?
        logs.create loggable: loggable, event: "#{loggable.class}::#{opts[:event]}"
      end

      def ratings
        Tempora.redis.hgetall Tempora::KeyMapper.logger_key self
      end

      def similarity_with logger
        Tempora::Recommender::Core.similarity self, logger
      end

      def predict loggable
        Tempora::Recommender::Core.prediction self, loggable
      end

      def is_logger?
        true
      end

      # Is self associated with loggable?
      # @param loggable
      # @return [Boolean]
      def assoc_with? obj
        obj.is_loggable? && is_tempora_assoc?(obj).present?
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
          assoc = self.send(self.class.tempora_assoc.detect{
            |a| a.klass == loggable_class
          }.plural_name)
        end
      end
    end
  end
end