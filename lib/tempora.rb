require "tempora/version"
require "tempora/configuration"
require "tempora/logging/logger"
require "tempora/logging/loggable"
require "tempora/logging/log"
require "tempora/logging/core"
require "tempora/logging/event"

module Tempora
  class << self
    def redis()
      config.redis
    end
  end
end

if defined? ActiveRecord::Base
  ActiveRecord::Base.send :include, Tempora::Logging::Logger
  ActiveRecord::Base.send :include, Tempora::Logging::Loggable
end