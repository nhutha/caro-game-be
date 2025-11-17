# frozen_string_literal: true

module Mutations
  class ForfeitGame < BaseMutation
    description "Forfeit the game (give up)"
    
    argument :game_id, ID, required: true

    field :game, Types::GameType, null: false

    def resolve(game_id:)
      require_authentication!
      
      game = Game.find(game_id)
      
      unless game.forfeit(current_user)
        raise GraphQL::ExecutionError, "Cannot forfeit this game"
      end
      
      Rails.logger.info "🏳️  #{current_user.username} forfeited game #{game.id}"
      
      # Trigger subscription
      CaroGameBeSchema.subscriptions.trigger(
        :game_updated,
        { game_id: game.id.to_s },
        {
          game: game.reload,
          event_type: 'game_forfeited',
          updated_by: current_user
        }
      )
      
      { game: game }
    end
  end
end
