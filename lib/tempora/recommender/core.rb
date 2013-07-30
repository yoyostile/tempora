module Tempora
  module Recommender
    class Core
      class << self

        LOGGER_REG = /(?<logger>\w+)::(?<logger_id>\d+)/
        LOGGABLE_REG = /(?<loggable>\w+)::(?<loggable_id>\d+)/

        # Calculates the similarity between two loggers
        # @param logger_a
        # @param logger_b
        # @return [Integer] similarity between -1 (lowest similarity) and 1 (highest similarity)
        def similarity logger_a, logger_b, force = false
          return unless logger_a.is_logger? || logger_b.is_logger?
          res = Tempora.redis.hget(Tempora::KeyMapper.similarity_key(logger_a), "#{logger_b.class}::#{logger_b.id}")
          return res.to_f if res && !force
          diff = get_shared_items logger_a, logger_b
          return -1 if diff.empty?
          avg_rating_a = average_rating_for logger_a, diff
          avg_rating_b = average_rating_for logger_b, diff
          items_a = get_all_items_for logger_a
          items_b = get_all_items_for logger_b
          items_a = items_a.select{ |k,v| items_b.include? k }
          items_b = items_b.select{ |k,v| items_a.include? k }

          if items_a.values.sum.to_f / items_a.length.to_f == avg_rating_a &&
            items_b.values.sum.to_f / items_b.length.to_f == avg_rating_b
            return 1
          end

          numerator = 0
          denominator_a = 0
          denominator_b = 0
          items_a.keys.each do |k|
            numerator += (items_a[k].to_f - avg_rating_a) * (items_b[k].to_f - avg_rating_b)
            denominator_a += (items_a[k].to_f - avg_rating_a)**2
            denominator_b += (items_b[k].to_f - avg_rating_b)**2
          end
          return -1 if numerator == 0 && (denominator_a <= 0 || denominator_b <= 0) # or -1. yeah.
          res = numerator / (Math.sqrt(denominator_a) * Math.sqrt(denominator_b))
          Tempora.redis.hset(Tempora::KeyMapper.similarity_key(logger_a), "#{logger_b.class}::#{logger_b.id}", res)
          res
        end

        def get_all_items_for logger, key = nil
          Tempora.redis.hgetall(key || Tempora::KeyMapper.logger_key(logger))
        end

        # Calculates the average rating for one logger
        # Uses all items if diff = nil, otherwise it uses only the items from diff
        # @param logger
        # @param diff list of items
        # @return [Integer] average rating
        def average_rating_for logger, diff = nil
          if diff
            avg_rating = Tempora.redis.hmget Tempora::KeyMapper.logger_key(logger), diff
          else
            avg_rating = get_all_items_for logger
            avg_rating = avg_rating.values
          end
          return 0 if avg_rating.empty?
          avg_rating = avg_rating.collect{ |s| s.to_f }.sum / avg_rating.length
        end

        # Predicts the rating for a logger and a loggable
        # @param logger
        # @param loggable
        # @return [Integer] predicted rating for the item
        def prediction logger, loggable
          rating = Tempora.redis.hget(Tempora::KeyMapper.logger_key(logger), "#{loggable.class}::#{loggable.id}")
          return rating if rating
          avg = average_rating_for logger
          nn = nearest_neighbors_for logger

          numerator = 0
          denominator = 0
          nn.each do |k|
            reg = LOGGER_REG.match k
            logger_b = reg["logger"].constantize.find reg["logger_id"]
            r_b = Tempora.redis.hget(Tempora::KeyMapper.logger_key(logger_b), "#{loggable.class}::#{loggable.id}").to_f
            avg_b = average_rating_for logger_b
            numerator += similarity(logger, logger_b) * (r_b - avg_b)
            denominator += similarity logger, logger_b
          end

          avg + (numerator/denominator)
        end

        # Gives a list of recommended items
        # @param logger
        # @param items [Integer] - number of items
        # @return [Array] of items
        def recommendation_list logger, items = 10
          list = []
          items_a = get_all_items_for logger
          nearest_neighbors_for(logger).each do |k|
            reg = LOGGER_REG.match k
            logger_b = reg["logger"].constantize.find_by_id reg["logger_id"]
            items_b = get_all_items_for logger_b if logger_b
            items_b = items_b.select{ |k,v| !items_a.include? k } if items_b
            next if items_b.empty?
            reg2 = LOGGABLE_REG.match items_b.keys.first
            loggable = reg2["loggable"].constantize.find reg2["loggable_id"]
            list.push loggable unless list.include? loggable
          end
          list
        end

        # @param logger_a
        # @param logger_b
        # @return [Array] keys for all items rated by logger_a AND logger_b
        def get_shared_items logger_a, logger_b
          items_a = get_all_items_for logger_a
          items_b = get_all_items_for logger_b
          items_a = items_a.select{ |k,v| items_b.include? k }
          items_a.keys
        end

        def generate_nearest_neighbors_for logger
          logger.class.find_each do |logger_b|
            next if logger == logger_b
            sim = similarity(logger, logger_b)
            Tempora.redis.hset(Tempora::KeyMapper.nearest_neighbors_key(logger),
              "#{logger_b.class}::#{logger_b.id}", sim) #if sim > -0.5
          end
        end

        # @param logger
        # @param force [boolean] - forces a new generation of nearest neighbors
        # @return a list of nearest neighbors sorted descending by similarity
        def nearest_neighbors_for logger, force = false
          nnkey = Tempora::KeyMapper.nearest_neighbors_key(logger)
          nn = get_all_items_for logger, nnkey
          if nn.empty? || force
            generate_nearest_neighbors_for logger
            nn = get_all_items_for logger, nnkey
          end
          nn.sort_by{|v| v[1].to_f}.reverse[0..Tempora.config.nearest_neighbors].map{ |x| x[0] }
        end
      end
    end
  end
end