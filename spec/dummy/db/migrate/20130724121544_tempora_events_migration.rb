class TemporaEventsMigration < ActiveRecord::Migration

  def self.up
    create_table :tempora_events do |t|
      t.string :name
      t.float :weight
      t.timestamps
    end
  end

  def self.down
    drop_table :tempora_events
  end
end
