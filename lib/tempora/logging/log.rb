module Tempora
  module Logging
    class Log < ActiveRecord::Base
      self.table_name = 'tempora_logs'
      belongs_to :loggable, :polymorphic => true
      belongs_to :logger, :polymorphic => true

      scope :grouped_loggables, -> {
        group(:loggable_id, :loggable_type).select([:loggable_id, :loggable_type])
      }

      def self.grouped_events(loggable)
        where(loggable_id: loggable.id, loggable_type: loggable.class).count(group: :event)
      end

      if Rails.version < "4.0.0"
        attr_accessible :loggable, :event
      end
    end
  end
end
