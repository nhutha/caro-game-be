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
      validate_player_authorization(game)

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

    private

    def validate_player_authorization(game)
      player_ids = [ game.player_1_id, game.player_2_id ]

      unless player_ids.include?(context[:current_user]&.id)
        raise Error::ForbiddenError.new("You are not a player in this game")
      end
    end
  end
end
