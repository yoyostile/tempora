module Tempora
  module Logging
    class Core
      MAX_RATING = 5

      def self.process_weights
        count_all = Tempora::Logging::Log.count
        Tempora::Logging::Log.group('event').pluck(:event).each do |event|
          e = Event.find_or_create_by_name event
          count = Tempora::Logging::Log.where('event = ?', event).count
          e.update_attribute :weight, (count_all.to_f/count.to_f)
        end
      end

      def self.generate_ratings logger_class, loggable_class
        if Event.count < Tempora::Logging::Log.group('event').count.count
          raise Error, 'You should generate the weights table first'
        end
        gl_ratings = {}
        logger_class.find_each do |logger|
          ratings = {}
          loggable_class.find_each do |loggable|
            log = logger.logs.where(loggable_id: loggable.id, loggable_type: loggable.type)
            grouped_events = log.count(group: :event)
            grouped_events.each do |k, e|
              weight = Tempora::Logging::Event.find_by_name(k).try(:weight)
              r = (weight * e > MAX_RATING) ? MAX_RATING : weight * e if weight
              r = MAX_RATING if logger.assoc_with? loggable
              ratings["#{loggable_class}::#{loggable.id}"] = r
            end
            if log.empty?
              r = MAX_RATING if logger.assoc_with? loggable
              ratings["#{loggable_class}::#{loggable.id}"] = r
            end
          end
          gl_ratings["#{logger_class}::#{logger.id}"] = ratings
        end
        gl_ratings
      end

      def self.persist_hash hash
        hash.each do |k, v|
          v.each do |i, j|
            Tempora.redis.hset("#{Tempora.config.redis_namespace}::#{k}", i, j)
          end
        end
      end
    end
  end
end