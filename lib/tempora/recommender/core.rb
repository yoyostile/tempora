module Tempora
  module Recommender
    def similarity logger_a, logger_b
      items_a = Tempora.redis.hgetall Tempora::KeyMapper.logger_key logger_a
      items_b = Tempora.redis.hgetall Tempora::KeyMapper.logger_key logger_b
    end
  end
end