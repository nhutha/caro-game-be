class RenamePlayerColumnsInGames < ActiveRecord::Migration[8.0]
  def change
    rename_column :games, :player1_id, :player_1_id
    rename_column :games, :player2_id, :player_2_id
  end
end
