# frozen_string_literal: true

module Subscriptions
  class GameUpdated < BaseSubscription
    description "Subscribe to game updates"
    
    argument :game_id, ID, required: true

    field :game, Types::GameType, null: false
    field :move, Types::MoveType, null: true
    field :event_type, String, null: false

    def subscribe(game_id:)
      Rails.logger.info "🔔 New subscriber to game_updated"
      Rails.logger.info "   Game ID: #{game_id}"
      Rails.logger.info "   User: #{context[:current_user]&.username || 'anonymous'}"
      
      game = Game.find(game_id)
      
      # Check permission - chỉ player mới subscribe được
      unless [game.player_1_id, game.player_2_id].include?(context[:current_user]&.id)
        Rails.logger.error "   ❌ User not authorized for this game"
        raise GraphQL::ExecutionError, "You are not a player in this game"
      end
      
      Rails.logger.info "   ✅ Subscription registered for game: #{game.id}"
      
      {}
    end

    def update(game_id:)
      Rails.logger.info "📤 Sending game_updated event"
      Rails.logger.info "   Game ID: #{game_id}"
      Rails.logger.info "   Event: #{object[:event_type]}"
      
      {
        game: object[:game],
        move: object[:move],
        event_type: object[:event_type]
      }
    end
  end
end
