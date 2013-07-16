module Tempora
  module Logging
    class Core
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
            byebug
            grouped_events = log.count(group: :event)
            grouped_events.each do |k, e|
              weight = Tempora::Logging::Event.find_by_name(k).try(:weight)
              ratings[loggable.id] = weight * e if weight
            end
          end
          gl_ratings[logger.id] = ratings
        end
        p gl_ratings
      end
    end
  end
end