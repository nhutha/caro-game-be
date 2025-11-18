class CreateMoves < ActiveRecord::Migration[8.0]
  def change
    create_table :moves do |t|
      t.references :game, null: false, foreign_key: true
      t.references :user, null: false, foreign_key: true
      t.integer :row, null: false
      t.integer :col, null: false
      t.string :symbol, null: false
      t.integer :turn_number, null: false

      t.timestamps
    end

    add_index :moves, [ :game_id, :turn_number ], unique: true
    add_index :moves, [ :game_id, :row, :col ]
  end
end
