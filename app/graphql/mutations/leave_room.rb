# frozen_string_literal: true

module Mutations
  class LeaveRoom < BaseMutation
    description "Leave a room"

    argument :room_id, ID, required: true

    field :success, Boolean, null: false
    field :message, String, null: true

    def resolve(room_id:)
      require_authentication!

      room = Room.find(room_id)

      # Check if user is in the room
      unless room.master_id == current_user.id || room.guest_id == current_user.id
        raise GraphQL::ExecutionError, "You are not in this room"
      end

      # Check if game is already playing
      if room.playing? || room.finished?
        raise GraphQL::ExecutionError, "Cannot leave room while game is in progress or finished"
      end

      # If master leaves, delete the room
      if room.master_id == current_user.id
        Rails.logger.info "🚪 Master #{current_user.username} leaving room #{room.id}, deleting room"

        # Trigger room_updated to notify guest before deletion
        CaroGameBeSchema.subscriptions.trigger(
          :room_updated,
          { room_id: room.id.to_s },
          {
            room: room,
            event_type: 'room_closed',
            updated_by: current_user
          }
        )

        room.destroy!
        return { success: true, message: "Room deleted" }
      end

      # If guest leaves, just remove them
      if room.guest_id == current_user.id
        room.update!(guest: nil)

        # Trigger room_updated subscription
        CaroGameBeSchema.subscriptions.trigger(
          :room_updated,
          { room_id: room.id.to_s },
          {
            room: room.reload,
            event_type: 'player_left',
            updated_by: current_user
          }
        )
        return { success: true, message: "Left room successfully" }
      end

      { success: false, message: "Unable to leave room" }
    end
  end
end
