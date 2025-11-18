# frozen_string_literal: true

module Mutations
  class StartGame < BaseMutation
    description "Start a game in a room (master only)"

    argument :room_id, ID, required: true

    field :game, Types::GameType, null: false

    def resolve(room_id:)
      require_authentication!

      room = Room.find(room_id)
      validate_game_start(room)

      game = create_game(room)
      trigger_room_update(room)

      { game: game }
    end

    private

    def validate_game_start(room)
      unless room.master_id == current_user.id
        raise Error::ForbiddenError.new("Only room master can start the game")
      end

      unless room.full?
        raise Error::ValidationError.new("Need 2 players to start the game")
      end

      if room.game.present?
        raise Error::ValidationError.new("Game has already started")
      end
    end

    def create_game(room)
      game = Game.create!(
        room: room,
        player_1: room.master,
        player_2: room.guest,
        current_turn_player: room.master
      )

      room.update!(status: :playing)
      game
    end

    def trigger_room_update(room)
      CaroGameBeSchema.subscriptions.trigger(
        :room_updated,
        { room_id: room.id.to_s },
        {
          room: room.reload,
          event_type: "game_started",
          updated_by: current_user
        }
      )
    end
  end
end
