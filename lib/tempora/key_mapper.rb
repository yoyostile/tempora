module Tempora
  class KeyMapper
    class << self
      def logger_key logger
        if logger.is_logger?
          "#{Tempora.config.redis_namespace}::#{logger.class}::#{logger.id}"
        else
          raise Error, "Model is not logger"
        end
      end

      def loggable_key loggable
        if loggable.is_loggable?
          "#{Tempora.config.redis_namespace}::#{loggable.class}::#{loggable.id}"
        else
          raise Error, "Model is not loggable"
        end
      end
    end
  end
end