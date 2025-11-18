class Game < ApplicationRecord
  # Associations
  belongs_to :room
  belongs_to :player_1, class_name: "User", foreign_key: "player_1_id"
  belongs_to :player_2, class_name: "User", foreign_key: "player_2_id"
  belongs_to :winner, class_name: "User", optional: true
  belongs_to :current_turn_player, class_name: "User"
  has_many :moves, -> { order(created_at: :asc) }, dependent: :destroy

  # Constants
  BOARD_SIZE = 15
  WIN_CONDITION = 5

  DIRECTIONS = [
    [ [ 0, 1 ], [ 0, -1 ] ],
    [ [ 1, 0 ], [ -1, 0 ] ],
    [ [ 1, 1 ], [ -1, -1 ] ],
    [ [ 1, -1 ], [ -1, 1 ] ]
  ].freeze

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

  # Callbacks
  before_validation :initialize_board, on: :create
  after_update :update_statistics, if: :saved_change_to_status?

  # Instance methods
  def initialize_board
    self.board_state = Array.new(BOARD_SIZE) { Array.new(BOARD_SIZE, nil) }
    self.turn_number = 0
    self.started_at = Time.current
  end

  # Make a move on the board
  #
  # @param user [User] the user making the move
  # @param row [Integer] the row position (0-14)
  # @param col [Integer] the column position (0-14)
  # @return [Hash] result containing success status, move, and game state
  def make_move(user, row, col)
    return { success: false, error: "Not your turn" } unless can_make_move?(user, row, col)

    symbol = symbol_for_player(user)
    update_board(row, col, symbol)
    move = create_move_record(user, row, col, symbol)
    switch_turn

    game_result = check_game_end(row, col, symbol, user, move)
    return game_result if game_result

    save!
    { success: true, game_ended: false, move: move }
  end

  # Check if a user can make a move at the given position
  #
  # @param user [User] the user attempting to move
  # @param row [Integer] the row position
  # @param col [Integer] the column position
  # @return [Boolean] true if the move is valid
  def can_make_move?(user, row, col)
    playing? &&
      current_turn_player_id == user.id &&
      valid_position?(row, col) &&
      board_state[row][col].nil?
  end

  def valid_position?(row, col)
    row.between?(0, BOARD_SIZE - 1) && col.between?(0, BOARD_SIZE - 1)
  end

  def board_full?
    board_state.flatten.none?(&:nil?)
  end

  # Check if there's a winning condition at the given position
  #
  # @param row [Integer] the row of the last move
  # @param col [Integer] the column of the last move
  # @param symbol [String] 'X' or 'O'
  # @return [Boolean] true if this move creates a win
  def check_win(row, col, symbol)
    DIRECTIONS.any? do |dir|
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
    positions = [ [ row, col ] ]

    direction.each do |dx, dy|
      x, y = row, col
      loop do
        x += dx
        y += dy
        break unless valid_position?(x, y) && board_state[x][y] == symbol
        positions << [ x, y ]
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

  # Forfeit the current game
  #
  # @param user [User] the user who is forfeiting
  # @return [Boolean] true if forfeit was successful
  def forfeit(user)
    return false unless playing?
    return false unless player?(user)

    opponent = determine_opponent(user)
    finish_game(winner: opponent, result_type: :forfeit)
    save!
  end

  # Check if a user is a player in this game
  #
  # @param user [User] the user to check
  # @return [Boolean] true if user is player_1 or player_2
  def player?(user)
    [ player_1_id, player_2_id ].include?(user.id)
  end

  private

  # Determine the symbol (X or O) for a player
  #
  # @param user [User] the player
  # @return [String] 'X' for player_1, 'O' for player_2
  def symbol_for_player(user)
    user.id == player_1_id ? "X" : "O"
  end

  # Update the board state with the move
  #
  # @param row [Integer] row position
  # @param col [Integer] column position
  # @param symbol [String] 'X' or 'O'
  def update_board(row, col, symbol)
    board_state[row][col] = symbol
    self.turn_number += 1
    self.last_move_at = Time.current
  end

  # Create a move record in the database
  #
  # @param user [User] the player making the move
  # @param row [Integer] row position
  # @param col [Integer] column position
  # @param symbol [String] 'X' or 'O'
  # @return [Move] the created move record
  def create_move_record(user, row, col, symbol)
    moves.create!(
      user: user,
      row: row,
      col: col,
      symbol: symbol,
      turn_number: turn_number
    )
  end

  # Switch to the next player's turn
  def switch_turn
    self.current_turn_player = determine_opponent(current_turn_player)
  end

  # Check if the game has ended (win or draw)
  #
  # @param row [Integer] row of last move
  # @param col [Integer] column of last move
  # @param symbol [String] 'X' or 'O'
  # @param user [User] the player who made the move
  # @param move [Move] the move record
  # @return [Hash, nil] result hash if game ended, nil otherwise
  def check_game_end(row, col, symbol, user, move)
    if check_win(row, col, symbol)
      finish_game(winner: user, result_type: :win)
      save!
      return { success: true, game_ended: true, winner: user, move: move }
    end

    if board_full?
      finish_game(result_type: :draw)
      save!
      return { success: true, game_ended: true, draw: true, move: move }
    end

    nil
  end

  # Determine the opponent of a given user
  #
  # @param user [User] the current user
  # @return [User] the opponent
  def determine_opponent(user)
    user.id == player_1_id ? player_2 : player_1
  end

  # Update player statistics after game ends
  def update_statistics
    return unless finished?

    if result_draw?
      # Draw case
      player_1.increment!(:draws)
      player_1.increment!(:points, 1)
      player_2.increment!(:draws)
      player_2.increment!(:points, 1)
    elsif winner_id.present?
      # Win case
      winner.increment!(:wins)
      winner.increment!(:points, 3)

      # Loser
      loser = winner_id == player_1_id ? player_2 : player_1
      loser.increment!(:losses)
    end
  end
end
