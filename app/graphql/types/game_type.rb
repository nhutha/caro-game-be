# frozen_string_literal: true

module Types
  class GameType < Types::BaseObject
    field :id, ID, null: false
    field :room, Types::RoomType, null: false
    field :player_1, Types::UserType, null: false, method: :player_1
    field :player_2, Types::UserType, null: false, method: :player_2
    field :winner, Types::UserType, null: true
    field :current_turn_player, Types::UserType, null: false
    field :status, String, null: false
    field :result_type, String, null: true
    field :board_state, [[String]], null: false
    field :winning_positions, [[Integer]], null: false
    field :turn_number, Integer, null: false
    field :started_at, GraphQL::Types::ISO8601DateTime, null: false
    field :finished_at, GraphQL::Types::ISO8601DateTime, null: true
    field :last_move_at, GraphQL::Types::ISO8601DateTime, null: true
    field :moves, [Types::MoveType], null: false
    field :created_at, GraphQL::Types::ISO8601DateTime, null: false
    field :updated_at, GraphQL::Types::ISO8601DateTime, null: false
    
    def status
      object.status.capitalize
    end
    
    def result_type
      object.result_type&.capitalize
    end
  end
end
