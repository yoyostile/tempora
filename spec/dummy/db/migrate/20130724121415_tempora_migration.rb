class TemporaMigration < ActiveRecord::Migration

  def self.up
    create_table :tempora_logs do |t|
      t.references :logger, :polymorphic => true
      t.references :loggable, :polymorphic => true
      t.datetime :created_at
      t.string :event
    end
  end

  def self.down
    drop_table :tempora_logs
  end
end
