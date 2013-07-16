class TemporaEventsMigration < ActiveRecord::Migration

  def self.up
    create_table :events do |t|
      t.string :name
      t.float :weight
      t.timestamps
    end
  end

  def self.down
    drop_table :events
  end
end
