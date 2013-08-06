require "tempora/version"
require "tempora/configuration"
require "tempora/key_mapper.rb"
require "tempora/logging/base"
require "tempora/logging/logger"
require "tempora/logging/loggable"
require "tempora/logging/acts_as_logger"
require "tempora/logging/acts_as_loggable"
require "tempora/logging/log"
require "tempora/logging/core"
require "tempora/logging/event"
require "tempora/recommender/core"

module Tempora
  class << self
    def redis()
      config.redis
    end
  end
end

if defined? ActiveRecord::Base
  ActiveRecord::Base.send :include, Tempora::Logging::ActsAsLogger
  ActiveRecord::Base.send :include, Tempora::Logging::ActsAsLoggable
end