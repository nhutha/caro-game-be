class CreateGames < ActiveRecord::Migration[8.0]
  def change
    create_table :games do |t|
      t.references :room, null: false, foreign_key: true
      t.references :player1, null: false, foreign_key: { to_table: :users }
      t.references :player2, null: false, foreign_key: { to_table: :users }
      t.references :winner, null: true, foreign_key: { to_table: :users }
      t.references :current_turn_player, null: false, foreign_key: { to_table: :users }

      t.integer :status, default: 0, null: false
      t.integer :result_type
      t.integer :turn_number, default: 0, null: false

      t.jsonb :board_state, default: [], null: false
      t.jsonb :winning_positions, default: []

      t.datetime :started_at
      t.datetime :finished_at
      t.datetime :last_move_at

      t.timestamps
    end

    add_index :games, :status
    add_index :games, :result_type
    add_index :games, [ :player1_id, :player2_id ]
  end
end
