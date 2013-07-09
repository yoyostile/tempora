module Tempora
end

require "tempora/logging/logger"
require "tempora/logging/loggable"
require "tempora/logging/log"

if defined? ActiveRecord::Base
  ActiveRecord::Base.send :include, Tempora::Logging::Logger
end