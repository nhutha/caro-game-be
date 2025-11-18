# frozen_string_literal: true

module Mutations
  class JoinRoom < BaseMutation
    description "Join an existing room as a guest"

    argument :room_id, ID, required: true

    field :room, Types::RoomType, null: false

    def resolve(room_id:)
      require_authentication!

      room = Room.find(room_id)
      validate_room_availability(room)

      join_as_guest(room)
      trigger_room_update(room)

      { room: room }
    end

    private

    def validate_room_availability(room)
      if room.guest_id.present? && room.guest_id != current_user.id
        raise Error::ValidationError.new("Room is already full")
      end

      if room.master_id == current_user.id
        raise Error::ValidationError.new("You are already the master of this room")
      end
    end

    def join_as_guest(room)
      room.update!(guest: current_user)
    end

    def trigger_room_update(room)
      CaroGameBeSchema.subscriptions.trigger(
        :room_updated,
        { room_id: room.id.to_s },
        {
          room: room.reload,
          event_type: "player_joined",
          updated_by: current_user
        }
      )
    end
  end
end
