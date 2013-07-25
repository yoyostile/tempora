module Tempora
  module Recommender
    class Core
      class << self
        def similarity logger_a, logger_b
          diff = diff_items logger_a, logger_b
          return -1 if diff.empty?
          avg_rating_a = average_rating_for logger_a, diff
          avg_rating_b = average_rating_for logger_b, diff
          items_a = Tempora.redis.hgetall Tempora::KeyMapper.logger_key logger_a
          items_b = Tempora.redis.hgetall Tempora::KeyMapper.logger_key logger_b
          items_a = items_a.select{ |k,v| items_b.include? k }
          items_b = items_b.select{ |k,v| items_a.include? k }

          numerator = 0
          denominator_a = 0
          denominator_b = 0
          items_a.keys.each do |k|
            numerator += (items_a[k].to_f - avg_rating_a) * (items_b[k].to_f - avg_rating_b)
            denominator_a += (items_a[k].to_f - avg_rating_a)**2
            denominator_b += (items_b[k].to_f - avg_rating_b)**2
          end
          return -1 if numerator == 0 && (denominator_a == 0 || denominator_b == 0) # or -1. yeah.
          numerator / (Math.sqrt(denominator_a) * Math.sqrt(denominator_b))
        end

        def average_rating_for logger, diff = nil
          if diff
            avg_rating = Tempora.redis.hmget Tempora::KeyMapper.logger_key(logger), diff
          else
            avg_rating = Tempora.redis.hgetall Tempora::KeyMapper.logger_key(logger)
            avg_rating = avg_rating.values
          end
          avg_rating = avg_rating.collect{ |s| s.to_f }.sum / avg_rating.length
        end

        def prediction logger, loggable
          return if Tempora.redis.hget(Tempora::KeyMapper.logger_key(logger), "#{loggable.class}::#{loggable.id}")
          avg = average_rating_for logger
          nn = nearest_neighbors_for logger

          numerator = 0
          denominator = 0
          nn.each do |k|
            reg = /(?<logger>\w+)::(?<logger_id>\d+)/.match k
            logger_b = reg["logger"].constantize.find reg["logger_id"]
            r_b = Tempora.redis.hget(Tempora::KeyMapper.logger_key(logger_b), "#{loggable.class}::#{loggable.id}").to_f
            avg_b = average_rating_for logger_b
            numerator += similarity(logger, logger_b) * (r_b - avg_b)
            denominator += similarity logger, logger_b
          end

          avg + (numerator/denominator)
        end

        def recommendation_list logger
          nn = nearest_neighbors_for logger
          list = []
          items_a = Tempora.redis.hgetall Tempora::KeyMapper.logger_key logger
          nn.each do |k|
            reg = /(?<logger>\w+)::(?<logger_id>\d+)/.match k
            logger_b = reg["logger"].constantize.find reg["logger_id"]
            items_b = Tempora.redis.hgetall Tempora::KeyMapper.logger_key logger_b
            items_b = items_b.select{ |k,v| !items_a.include? k }
            next if items_b.empty?
            reg2 = /(?<loggable>\w+)::(?<loggable_id>\d+)/.match items_b.keys.first
            loggable = reg2["loggable"].constantize.find reg2["loggable_id"]
            list.push loggable unless list.include? loggable
          end
          list
        end

        def diff_items logger_a, logger_b
          items_a = Tempora.redis.hgetall Tempora::KeyMapper.logger_key logger_a
          items_b = Tempora.redis.hgetall Tempora::KeyMapper.logger_key logger_b
          items_a = items_a.select{ |k,v| items_b.include? k }
          items_a.keys
        end

        def generate_nearest_neighbors_for logger
          logger.class.find_each do |logger_b|
            next if logger == logger_b
            Tempora.redis.hset(Tempora::KeyMapper.nearest_neighbors_key(logger),
              "#{logger_b.class}::#{logger_b.id}", similarity(logger, logger_b))
          end
        end

        def nearest_neighbors_for logger, force = false
          nn = Tempora.redis.hgetall(Tempora::KeyMapper.nearest_neighbors_key(logger))
          if nn.empty? || force
            generate_nearest_neighbors_for logger
            nn = Tempora.redis.hgetall(Tempora::KeyMapper.nearest_neighbors_key(logger))
          end
          nn.sort_by{|v| v[1].to_f}.reverse[0..Tempora.config.nearest_neighbors].map{ |x| x[0] }
        end
      end
    end
  end
end