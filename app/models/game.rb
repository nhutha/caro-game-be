class Game < ApplicationRecord
  # Associations
  belongs_to :room
  belongs_to :player_1, class_name: 'User', foreign_key: 'player_1_id'
  belongs_to :player_2, class_name: 'User', foreign_key: 'player_2_id'
  belongs_to :winner, class_name: 'User', optional: true
  belongs_to :current_turn_player, class_name: 'User'
  has_many :moves, -> { order(created_at: :asc) }, dependent: :destroy
  
  # Constants
  BOARD_SIZE = 15
  WIN_CONDITION = 5
  
  # Validations
  validates :board_state, presence: true
  validates :turn_number, numericality: { greater_than_or_equal_to: 0 }
  
  # Enums
  enum :status, {
    playing: 0,
    finished: 1
  }
  
  enum :result_type, {
    win: 0,
    draw: 1,
    forfeit: 2
  }, prefix: :result
  
  # Serialization
  serialize :board_state, coder: JSON
  serialize :winning_positions, coder: JSON
  
  # Callbacks
  before_create :initialize_board
  after_update :update_statistics, if: :saved_change_to_status?
  
  # Instance methods
  def initialize_board
    self.board_state = Array.new(BOARD_SIZE) { Array.new(BOARD_SIZE, nil) }
    self.turn_number = 0
    self.started_at = Time.current
  end
  
  def make_move(user, row, col)
    return { success: false, error: "Not your turn" } unless can_make_move?(user, row, col)
    
    # Xác định ký hiệu (X hoặc O)
    symbol = user.id == player_1_id ? 'X' : 'O'
    
    # Cập nhật bàn cờ
    board_state[row][col] = symbol
    self.turn_number += 1
    self.last_move_at = Time.current
    
    # Tạo move record
    move = moves.create!(
      user: user,
      row: row,
      col: col,
      symbol: symbol,
      turn_number: turn_number
    )
    
    # Đổi lượt
    self.current_turn_player = (current_turn_player_id == player_1_id) ? player_2 : player_1
    
    # Kiểm tra thắng
    if check_win(row, col, symbol)
      finish_game(winner: user, result_type: :win)
      save!
      return { success: true, game_ended: true, winner: user, move: move }
    end
    
    # Kiểm tra hòa
    if board_full?
      finish_game(result_type: :draw)
      save!
      return { success: true, game_ended: true, draw: true, move: move }
    end
    
    save!
    { success: true, game_ended: false, move: move }
  end
  
  def can_make_move?(user, row, col)
    return false unless playing?
    return false unless current_turn_player_id == user.id
    return false unless valid_position?(row, col)
    return false unless board_state[row][col].nil?
    true
  end
  
  def valid_position?(row, col)
    row.between?(0, BOARD_SIZE - 1) && col.between?(0, BOARD_SIZE - 1)
  end
  
  def board_full?
    board_state.flatten.none?(&:nil?)
  end
  
  def check_win(row, col, symbol)
    directions = [
      [[0, 1], [0, -1]],   # Ngang →←
      [[1, 0], [-1, 0]],   # Dọc ↓↑
      [[1, 1], [-1, -1]],  # Chéo ↘↖
      [[1, -1], [-1, 1]]   # Chéo ↙↗
    ]
    
    directions.any? do |dir|
      count = 1 + count_direction(row, col, symbol, dir[0][0], dir[0][1]) +
              count_direction(row, col, symbol, dir[1][0], dir[1][1])
      
      if count >= WIN_CONDITION
        store_winning_positions(row, col, dir, symbol)
        true
      else
        false
      end
    end
  end
  
  def count_direction(row, col, symbol, dx, dy)
    count = 0
    x, y = row + dx, col + dy
    
    while valid_position?(x, y) && board_state[x][y] == symbol
      count += 1
      x += dx
      y += dy
    end
    
    count
  end
  
  def store_winning_positions(row, col, direction, symbol)
    positions = [[row, col]]
    
    direction.each do |dx, dy|
      x, y = row, col
      loop do
        x += dx
        y += dy
        break unless valid_position?(x, y) && board_state[x][y] == symbol
        positions << [x, y]
      end
    end
    
    self.winning_positions = positions
  end
  
  def finish_game(winner: nil, result_type: :win)
    self.status = :finished
    self.winner = winner
    self.result_type = result_type
    self.finished_at = Time.current
    
    # Update room
    room.update!(status: :finished)
  end
  
  def forfeit(user)
    return false unless playing?
    return false unless [player_1_id, player_2_id].include?(user.id)
    
    winner = user.id == player_1_id ? player_2 : player_1
    finish_game(winner: winner, result_type: :forfeit)
    save!
  end
  
  private
  
  def update_statistics
    return unless finished?
    
    if result_draw?
      # Draw case
      player_1.increment!(:draws)
      player_1.increment!(:points, 1) # 1 điểm cho hòa
      player_2.increment!(:draws)
      player_2.increment!(:points, 1)
    elsif winner_id.present?
      # Win case
      winner.increment!(:wins)
      winner.increment!(:points, 3) # 3 điểm cho thắng
      
      # Loser
      loser = winner_id == player_1_id ? player_2 : player_1
      loser.increment!(:losses)
    end
  end
end
