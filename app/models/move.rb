class Move < ApplicationRecord
  # Associations
  belongs_to :game
  belongs_to :user
  
  # Validations
  validates :row, presence: true, numericality: { 
    greater_than_or_equal_to: 0, 
    less_than: Game::BOARD_SIZE 
  }
  validates :col, presence: true, numericality: { 
    greater_than_or_equal_to: 0, 
    less_than: Game::BOARD_SIZE 
  }
  validates :symbol, presence: true, inclusion: { in: %w[X O] }
  validates :turn_number, presence: true, numericality: { greater_than: 0 }
  
  # Scopes
  scope :by_turn, -> { order(turn_number: :asc) }
  scope :recent, -> { order(created_at: :desc) }
end
