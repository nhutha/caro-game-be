class AddStatisticsToUsers < ActiveRecord::Migration[8.0]
  def change
    add_column :users, :wins, :integer, default: 0, null: false
    add_column :users, :losses, :integer, default: 0, null: false
    add_column :users, :draws, :integer, default: 0, null: false
    add_column :users, :points, :integer, default: 0, null: false

    add_index :users, :points
    add_index :users, :wins
  end
end
