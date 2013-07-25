module Tempora
  module Logging
    class Core
      MAX_RATING = 5

      def self.process logger_class, loggable_class
        self.process_weights
        self.persist_hash self.generate_ratings logger_class, loggable_class
      end

      def self.process_weights
        count_all = Tempora::Logging::Log.count
        Tempora::Logging::Log.group('event').pluck(:event).each do |event|
          e = Tempora::Logging::Event.find_or_create_by_name event
          count = Tempora::Logging::Log.where('event = ?', event).count
          e.update_attribute :weight, (count_all.to_f/count.to_f)
        end
      end

      def self.generate_ratings logger_class, loggable_class
        if Tempora::Logging::Event.count < Tempora::Logging::Log.group('event').count.count
          raise Error, 'You should generate the weights table first'
        end
        gl_ratings = {}
        logger_class.find_each do |logger|
          ratings = {}
          logger_logs = logger.logs.group(:loggable_id)
          logger_logs.each do |log|
            loggable = log.loggable_type.constantize.find(log.loggable_id)
            grouped_events = logger.logs.where(loggable_id: loggable.id).count(group: :event)
            grouped_events.each do |k, e|
              weight = Tempora::Logging::Event.find_by_name(k).try(:weight)
              r = (weight * e > MAX_RATING) ? MAX_RATING : weight * e if weight
              r = MAX_RATING if logger.assoc_with? loggable
              ratings["#{loggable_class}::#{loggable.id}"] = r
            end
          end
          logger_assocs = logger.association_list loggable_class
          logger_assocs.each do |loggable|
            ratings["#{loggable.class}::#{loggable.id}"] = MAX_RATING
          end
          gl_ratings[Tempora::KeyMapper.logger_key logger] = ratings if ratings.present?
        end
        gl_ratings
      end

      def self.persist_hash hash
        hash.each do |k, v|
          v.each do |i, j|
            Tempora.redis.hset("#{k}", i, j)
          end
        end
      end
    end
  end
end