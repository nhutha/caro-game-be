# frozen_string_literal: true

module Mutations
  class ForfeitGame < BaseMutation
    description "Forfeit the current game"

    argument :game_id, ID, required: true

    field :game, Types::GameType, null: false

    def resolve(game_id:)
      require_authentication!

      game = Game.find(game_id)
      process_forfeit(game)
      trigger_game_update(game)

      { game: game }
    end

    private

    def process_forfeit(game)
      return if game.forfeit(current_user)

      raise GraphQL::ExecutionError, "Cannot forfeit this game"
    end

    def trigger_game_update(game)
      CaroGameBeSchema.subscriptions.trigger(
        :game_updated,
        { game_id: game.id.to_s },
        {
          game: game.reload,
          move: nil,
          event_type: "game_forfeited"
        }
      )
    end
  end
end
