module Tempora
  module Logging
    class Log < ActiveRecord::Base
      belongs_to :loggable, :polymorphic => true
      belongs_to :logger, :polymorphic => true

      attr_accessible :loggable, :weight, :event
    end
  end
end
