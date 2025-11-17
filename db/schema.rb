# This file is auto-generated from the current state of the database. Instead
# of editing this file, please use the migrations feature of Active Record to
# incrementally modify your database, and then regenerate this schema definition.
#
# This file is the source Rails uses to define your schema when running `bin/rails
# db:schema:load`. When creating a new database, `bin/rails db:schema:load` tends to
# be faster and is potentially less error prone than running all of your
# migrations from scratch. Old migrations may fail to apply correctly if those
# migrations use external dependencies or application code.
#
# It's strongly recommended that you check this file into your version control system.

ActiveRecord::Schema[8.0].define(version: 2025_11_17_180140) do
  # These are extensions that must be enabled in order to support this database
  enable_extension "pg_catalog.plpgsql"

  create_table "games", force: :cascade do |t|
    t.bigint "room_id", null: false
    t.bigint "player_1_id", null: false
    t.bigint "player_2_id", null: false
    t.bigint "winner_id"
    t.bigint "current_turn_player_id", null: false
    t.integer "status", default: 0, null: false
    t.integer "result_type"
    t.integer "turn_number", default: 0, null: false
    t.jsonb "board_state", default: [], null: false
    t.jsonb "winning_positions", default: []
    t.datetime "started_at"
    t.datetime "finished_at"
    t.datetime "last_move_at"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.index ["current_turn_player_id"], name: "index_games_on_current_turn_player_id"
    t.index ["player_1_id", "player_2_id"], name: "index_games_on_player_1_id_and_player_2_id"
    t.index ["player_1_id"], name: "index_games_on_player_1_id"
    t.index ["player_2_id"], name: "index_games_on_player_2_id"
    t.index ["result_type"], name: "index_games_on_result_type"
    t.index ["room_id"], name: "index_games_on_room_id"
    t.index ["status"], name: "index_games_on_status"
    t.index ["winner_id"], name: "index_games_on_winner_id"
  end

  create_table "moves", force: :cascade do |t|
    t.bigint "game_id", null: false
    t.bigint "user_id", null: false
    t.integer "row", null: false
    t.integer "col", null: false
    t.string "symbol", null: false
    t.integer "turn_number", null: false
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.index ["game_id", "row", "col"], name: "index_moves_on_game_id_and_row_and_col"
    t.index ["game_id", "turn_number"], name: "index_moves_on_game_id_and_turn_number", unique: true
    t.index ["game_id"], name: "index_moves_on_game_id"
    t.index ["user_id"], name: "index_moves_on_user_id"
  end

  create_table "refresh_tokens", force: :cascade do |t|
    t.bigint "user_id", null: false
    t.datetime "expiration_at", null: false
    t.string "token", null: false
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.index ["user_id"], name: "index_refresh_tokens_on_user_id"
  end

  create_table "rooms", force: :cascade do |t|
    t.string "name", null: false
    t.bigint "master_id", null: false
    t.bigint "guest_id"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.integer "status", default: 0, null: false
    t.index ["guest_id"], name: "index_rooms_on_guest_id"
    t.index ["master_id"], name: "index_rooms_on_master_id"
    t.index ["status"], name: "index_rooms_on_status"
  end

  create_table "solid_cable_messages", force: :cascade do |t|
    t.binary "channel", null: false
    t.binary "payload", null: false
    t.datetime "created_at", null: false
    t.bigint "channel_hash", null: false
    t.index ["channel"], name: "index_solid_cable_messages_on_channel"
    t.index ["channel_hash"], name: "index_solid_cable_messages_on_channel_hash"
    t.index ["created_at"], name: "index_solid_cable_messages_on_created_at"
  end

  create_table "users", force: :cascade do |t|
    t.string "username", null: false
    t.string "email", null: false
    t.string "password_digest", null: false
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.integer "wins", default: 0, null: false
    t.integer "losses", default: 0, null: false
    t.integer "draws", default: 0, null: false
    t.integer "points", default: 0, null: false
    t.index ["points"], name: "index_users_on_points"
    t.index ["wins"], name: "index_users_on_wins"
  end

  add_foreign_key "games", "rooms"
  add_foreign_key "games", "users", column: "current_turn_player_id"
  add_foreign_key "games", "users", column: "player_1_id"
  add_foreign_key "games", "users", column: "player_2_id"
  add_foreign_key "games", "users", column: "winner_id"
  add_foreign_key "moves", "games"
  add_foreign_key "moves", "users"
  add_foreign_key "refresh_tokens", "users"
  add_foreign_key "rooms", "users", column: "guest_id"
  add_foreign_key "rooms", "users", column: "master_id"
end
