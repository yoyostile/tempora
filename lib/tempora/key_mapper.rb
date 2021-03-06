module Tempora
  class KeyMapper
    class << self
      # @param logger
      # @return the redis-key for the given logger object

      [:logger, :loggable].each do |type|
        define_method("#{type}_key") do |model|
          if model.send("is_#{type}?")
            "#{Tempora.config.redis_namespace}::#{model.class}::#{model.id}"
          else
            raise Error, "Model is not #{type}"
          end
        end
      end

      # @param logger
      # @return the redis-key for the nearest neighbors fields for the given logger object

      [:nearest_neighbors, :similarity].each do |type|
        define_method("#{type}_key") do |logger|
          if logger.is_logger?
            "#{logger_key(logger)}::#{type.to_s.camelize}"
          else
            raise Error, "Model is not logger"
          end
        end
      end
    end
  end
end