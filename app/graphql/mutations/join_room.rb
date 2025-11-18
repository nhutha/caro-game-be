module Mutations
  class JoinRoom < BaseMutation
    argument :room_id, ID, required: true

    field :room, Types::RoomType, null: true

    def resolve(room_id:)
      require_authentication!

      room = Room.find(room_id)

      if room.guest_id.present? && room.guest_id != current_user.id
        raise GraphQL::ExecutionError, "Room is already occupied by another guest."
      end

      room.update!(guest: current_user)

      CaroGameBeSchema.subscriptions.trigger(
        :room_updated,
        { room_id: room.id.to_s },
        {
          room: room.reload,
          event_type: 'player_joined',
          updated_by: current_user
        }
      )

      { room: room }
    end
  end
end