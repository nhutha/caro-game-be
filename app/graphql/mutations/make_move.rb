# frozen_string_literal: true

module Mutations
  class MakeMove < BaseMutation
    description "Make a move in the game"
    
    argument :game_id, ID, required: true
    argument :row, Integer, required: true
    argument :col, Integer, required: true

    field :move, Types::MoveType, null: false
    field :game, Types::GameType, null: false
    field :game_ended, Boolean, null: false
    field :winner, Types::UserType, null: true

    def resolve(game_id:, row:, col:)
      require_authentication!
      
      game = Game.find(game_id)
      
      # Make move
      result = game.make_move(current_user, row, col)
      
      unless result[:success]
        raise GraphQL::ExecutionError, result[:error]
      end
      
      Rails.logger.info "♟️  Move made: #{current_user.username} -> (#{row}, #{col})"
      
      # Trigger subscription
      CaroGameBeSchema.subscriptions.trigger(
        :game_updated,
        { game_id: game.id.to_s },
        {
          game: game.reload,
          move: result[:move],
          event_type: result[:game_ended] ? 'game_ended' : 'move_made'
        }
      )
      
      {
        move: result[:move],
        game: game,
        game_ended: result[:game_ended] || false,
        winner: result[:winner]
      }
    end
  end
end
