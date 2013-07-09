class TemporaMigration < ActiveRecord::Migration

  def self.up
    create_table :logs do |t|
      t.references :logger, :polymorphic => true
      t.references :loggable, :polymorphic => true
      t.datetime :created_at
      t.string :event
      t.integer :weight
    end
  end

  def self.down
    drop_table :logs
  end
end
