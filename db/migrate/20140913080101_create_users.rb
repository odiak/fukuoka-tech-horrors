class CreateUsers < ActiveRecord::Migration
  def change
    create_table :users do |t|
      t.string :uid, null: false
      t.string :name, null: false, default: ""
      t.string :screen_name, null: false
      t.string :access_token, null: false
      t.string :access_token_secret, null: false
      t.string :icon, null: false, default: ""

      t.timestamps
    end

    add_index :users, :uid, unique: true
  end
end
