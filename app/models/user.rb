class User < ApplicationRecord
  has_secure_password

  # Associations
  has_many :refresh_tokens, dependent: :destroy
  has_many :room_as_masters, class_name: "Room", foreign_key: "master_id", dependent: :destroy
  has_many :room_as_guests, class_name: "Room", foreign_key: "guest_id", dependent: :nullify
  has_many :games_as_player_1, class_name: "Game", foreign_key: "player_1_id"
  has_many :games_as_player_2, class_name: "Game", foreign_key: "player_2_id"
  has_many :moves, dependent: :destroy

  # Validations
  validates :username, presence: true, uniqueness: true, length: { minimum: 3, maximum: 20 }
  validates :email, presence: true, uniqueness: true, format: { with: URI::MailTo::EMAIL_REGEXP }

  # Virtual attributes for leaderboard
  def total_games
    wins + losses + draws
  end

  def win_rate
    return 0 if total_games.zero?
    (wins.to_f / total_games * 100).round(2)
  end

  def all_games
    Game.where("player_1_id = ? OR player_2_id = ?", id, id)
  end
end
