module Tempora
  class Log < ::ActiveRecord::Base
    belongs_to :loggable, :polymorphic => true
    belongs_to :logger, :polymorphic => true
  end
end
