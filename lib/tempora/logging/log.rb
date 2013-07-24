module Tempora
  module Logging
    class Log < ActiveRecord::Base
      self.table_name = 'tempora_logs'
      belongs_to :loggable, :polymorphic => true
      belongs_to :logger, :polymorphic => true

      if Rails.version < "4.0.0"
        attr_accessible :loggable, :event
      end
    end
  end
end
