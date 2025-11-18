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
      validate_user_in_room(room)
      validate_room_status(room)

      if master_leaving?(room)
        handle_master_leave(room)
      elsif guest_leaving?(room)
        handle_guest_leave(room)
      else
        { success: false, message: "Unable to leave room" }
      end
    end

    private

    def validate_user_in_room(room)
      unless room.master_id == current_user.id || room.guest_id == current_user.id
        raise GraphQL::ExecutionError, "You are not in this room"
      end
    end

    def validate_room_status(room)
      if room.playing? || room.finished?
        raise GraphQL::ExecutionError, "Cannot leave room while game is in progress or finished"
      end
    end

    def master_leaving?(room)
      room.master_id == current_user.id
    end

    def guest_leaving?(room)
      room.guest_id == current_user.id
    end

    def handle_master_leave(room)
      trigger_room_closed(room)
      room.destroy!
      { success: true, message: "Room deleted" }
    end

    def handle_guest_leave(room)
      room.update!(guest: nil)
      trigger_player_left(room)
      { success: true, message: "Left room successfully" }
    end

    def trigger_room_closed(room)
      CaroGameBeSchema.subscriptions.trigger(
        :room_updated,
        { room_id: room.id.to_s },
        { room: room, event_type: "room_closed", updated_by: current_user }
      )
    end

    def trigger_player_left(room)
      CaroGameBeSchema.subscriptions.trigger(
        :room_updated,
        { room_id: room.id.to_s },
        { room: room.reload, event_type: "player_left", updated_by: current_user }
      )
    end
  end
end
