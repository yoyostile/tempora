class CreateFollowings < ActiveRecord::Migration
  def change
    create_table :followings do |t|
      t.integer :user_id, null: false
      t.integer :artist_id, null: false

      t.timestamps
    end
    add_index :followings, [ :user_id, :artist_id ], unique: true
  end
end
