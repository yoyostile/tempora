class TemporaMigration < ActiveRecord::Migration

  # logger.id
  # logger.type
  # loggable.id
  # loggable.type
  # viewed_at
  # view.duration
  # controller
  # action
  # params


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

  end
end
