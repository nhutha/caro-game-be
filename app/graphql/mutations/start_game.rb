# frozen_string_literal: true

module Mutations
  class StartGame < BaseMutation
    description "Start a game in a room"
    
    argument :room_id, ID, required: true

    field :game, Types::GameType, null: false

    def resolve(room_id:)
      require_authentication!
      
      room = Room.find(room_id)
      
      # Validate
      unless room.master_id == current_user.id
        raise GraphQL::ExecutionError, "Only room master can start the game"
      end
      
      unless room.full?
        raise GraphQL::ExecutionError, "Need 2 players to start"
      end
      
      if room.game.present?
        raise GraphQL::ExecutionError, "Game already started"
      end
      
      # Create game
      game = Game.create!(
        room: room,
        player_1: room.master,
        player_2: room.guest,
        current_turn_player: room.master # Master đi trước
      )
      
      # Update room
      room.update!(status: :playing)
      
      Rails.logger.info "🎮 Game started in room #{room.id}"
      
      # Trigger subscription
      CaroGameBeSchema.subscriptions.trigger(
        :room_updated,
        { room_id: room.id.to_s },
        {
          room: room.reload,
          event_type: 'game_started',
          updated_by: current_user
        }
      )
      
      { game: game }
    end
  end
end
