module Tempora
  module Logging
    class Event < ActiveRecord::Base
      if Rails.version < "4.0.0"
        attr_accessible :loggable, :event
      end

    end
  end
end

