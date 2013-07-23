require 'redis'

module Tempora
  class Configuration

    attr_accessor :redis

    attr_accessor :redis_namespace

    attr_accessor :nearest_neighbors

    def initialize
      @redis = Redis.new
      @redis_namespace = "Tempora::#{Rails.env}"
      @nearest_neighbors = 10
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