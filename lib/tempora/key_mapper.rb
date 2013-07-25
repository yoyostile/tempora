module Tempora
  class KeyMapper
    class << self
      # @param logger
      # @return the redis-key for the given logger object
      def logger_key logger
        if logger.is_logger?
          "#{Tempora.config.redis_namespace}::#{logger.class}::#{logger.id}"
        else
          raise Error, "Model is not logger"
        end
      end

      # @param loggable
      # @return the redis-key for the given loggable object
      def loggable_key loggable
        if loggable.is_loggable?
          "#{Tempora.config.redis_namespace}::#{loggable.class}::#{loggable.id}"
        else
          raise Error, "Model is not loggable"
        end
      end

      # @param logger
      # @return the redis-key for the nearest neighbors fields for the given logger object
      def nearest_neighbors_key logger
        if logger.is_logger?
          "#{logger_key(logger)}::NearestNeighbors"
        else
          raise Error, "Model is not logger"
        end
      end
    end
  end
end