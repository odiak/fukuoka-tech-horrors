class CreateVotings < ActiveRecord::Migration
  def change
    create_table :votings do |t|
      t.integer :user_id, null: false
      t.integer :story_id, null: false

      t.timestamps
    end

    add_index :votings, [:user_id, :story_id], unique: true
  end
end
