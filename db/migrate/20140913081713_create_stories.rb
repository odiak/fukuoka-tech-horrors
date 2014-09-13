class CreateStories < ActiveRecord::Migration
  def change
    create_table :stories do |t|
      t.string :title, null: false, default: ""
      t.text :body, null: false, default: ""
      t.integer :author_id, null: false
      t.integer :votes_count, null: false, default: 0

      t.timestamps
    end
  end
end
