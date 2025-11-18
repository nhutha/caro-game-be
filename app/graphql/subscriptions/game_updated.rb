# frozen_string_literal: true

module Subscriptions
  class GameUpdated < BaseSubscription
    description "Subscribe to game updates"

    argument :game_id, ID, required: true

    field :game, Types::GameType, null: false
    field :move, Types::MoveType, null: true
    field :event_type, String, null: false

    def subscribe(game_id:)
      game = Game.find(game_id)

      unless [game.player_1_id, game.player_2_id].include?(context[:current_user]&.id)
        raise GraphQL::ExecutionError, "You are not a player in this game"
      end

       {
          game: game,
          move: nil,
          event_type: "move_made"
        }
    end

    def update(game_id:)
      {
        game: object[:game],
        move: object[:move],
        event_type: object[:event_type]
      }
    end
  end
end
