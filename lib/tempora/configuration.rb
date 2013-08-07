require 'redis'

module Tempora
  class Configuration

    attr_accessor :redis

    attr_accessor :redis_namespace

    attr_accessor :nearest_neighbors

    attr_accessor :minimal_similarity

    # Initializes configuration
    def initialize
      @redis = $redis || Redis.new(:host => 'localhost', :port => 6379)
      @redis_namespace = "Tempora::#{Rails.env}"
      @nearest_neighbors = 20
      @minimal_similarity = -0.5
    end
  end

  class << self
    def configure
      @config ||= Configuration.new
      yield @config
    end

    def config
      @config ||= Configuration.new
    end
  end
end