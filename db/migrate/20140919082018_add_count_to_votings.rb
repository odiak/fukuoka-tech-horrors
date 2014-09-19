class AddCountToVotings < ActiveRecord::Migration
  def change
    add_column :votings, :count, :integer, null: false, default: 1
  end
end
