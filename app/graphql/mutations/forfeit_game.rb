# frozen_string_literal: true

module Mutations
  class ForfeitGame < BaseMutation
    argument :game_id, ID, required: true

    field :game, Types::GameType, null: false

    def resolve(game_id:)
      require_authentication!

      game = Game.find(game_id)

      unless game.forfeit(current_user)
        raise GraphQL::ExecutionError, "Cannot forfeit this game"
      end

      CaroGameBeSchema.subscriptions.trigger(
        :game_updated,
        { game_id: game.id.to_s },
        {
          game: game.reload,
          move: nil,
          event_type: 'game_forfeited'
        }
      )

      { game: game }
    end
  end
end
