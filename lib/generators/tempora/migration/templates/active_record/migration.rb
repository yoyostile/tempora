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
      t.references :tagger, :polymorphic => true
      t.datetime :created_at
      t.string :controller
      t.string :action
      t.integer :weight
    end
  end

  def self.down

  end
end
