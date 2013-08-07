module Tempora
  module Logging
    class Core
      MAX_RATING = Tempora.config.max_rating
      class << self

        # Triggers all necessary processing steps
        # @param logger_class
        # @param loggable_class
        def process logger_class, loggable_class
          self.process_weights
          self.persist_hash self.generate_ratings logger_class, loggable_class
        end

        # Processes weights
        def process_weights
          count_all = Tempora::Logging::Log.count
          Tempora::Logging::Log.group('event').pluck(:event).each do |event|
            e = Tempora::Logging::Event.find_or_create_by_name event
            count = Tempora::Logging::Log.where('event = ?', event).count
            e.update_attribute :weight, (count_all.to_f/count.to_f)
          end
        end

        # Generates Ratings for all instances of logger_class and loggable_class
        # @param logger_class
        # @param loggable_class
        # @return [Hash] with ratings
        def generate_ratings logger_class, loggable_class
          if Tempora::Logging::Event.count < Tempora::Logging::Log.group('event').count.count
            raise Error, 'You should generate the weights table first'
          end
          Hash.new.tap do |gl_ratings|
            logger_class.find_each do |logger|
              ratings = {}
              logger.logs.grouped_loggables.each do |log|
                loggable = log.loggable || next
                logger.logs.grouped_events(loggable).each do |k, e|
                  weight = Tempora::Logging::Event.where(name: k).pluck(:weight).first
                  ratings["#{loggable_class}::#{loggable.id}"] = weight * e
                end
              end
              logger.association_list(loggable_class).each do |loggable|
                ratings["#{loggable.class}::#{loggable.id}"] = MAX_RATING
              end
              gl_ratings[Tempora::KeyMapper.logger_key logger] = ratings if ratings.present?
            end
          end
        end

        # Saves Hash to Redis
        # @param hash [Hash]
        def persist_hash hash
          hash.each { |k, v| Tempora.redis.hmset k, v.flatten }
        end
      end
    end
  end
end