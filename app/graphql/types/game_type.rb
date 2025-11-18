# frozen_string_literal: true

module Types
  class GameType < Types::BaseObject
    description "A Caro game with 15x15 board"

    # Core fields
    field :id, ID, null: false
    field :room, Types::RoomType, null: false
    field :player_1, Types::UserType, null: false, method: :player_1
    field :player_2, Types::UserType, null: false, method: :player_2
    field :winner, Types::UserType, null: true
    field :current_turn_player, Types::UserType, null: false

    # Game state
    field :status, String, null: false
    field :result_type, String, null: true
    field :turn_number, Integer, null: false

    # Board data
    field :board_state, [[String, null: true]], null: false
    field :winning_positions, [[Integer, null: true]], null: false

    # Timestamps
    field :started_at, GraphQL::Types::ISO8601DateTime, null: false
    field :finished_at, GraphQL::Types::ISO8601DateTime, null: true
    field :last_move_at, GraphQL::Types::ISO8601DateTime, null: true
    field :created_at, GraphQL::Types::ISO8601DateTime, null: false
    field :updated_at, GraphQL::Types::ISO8601DateTime, null: false

    # Relations
    field :moves, [Types::MoveType], null: false

    # Custom resolvers
    def moves
      object.moves.order(:created_at)
    end

    def status
      object.status.capitalize
    end

    def result_type
      object.result_type&.capitalize
    end
  end
end
