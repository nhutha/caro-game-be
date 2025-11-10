class CreateRefreshTokens < ActiveRecord::Migration[8.0]
  def change
    create_table :refresh_tokens do |t|
      t.references :user, null: false, foreign_key: true
      t.datetime :expiration_at, null: false
      t.string :token, null: false
      t.timestamps
    end
  end
end
