class CreateRooms < ActiveRecord::Migration[8.0]
  def change
    create_table :rooms do |t|
      t.string :name, null: false
      t.references :master, null: false, foreign_key: { to_table: :users }
      t.references :guest, null: true, foreign_key: { to_table: :users }
      t.timestamps
    end
  end
end
