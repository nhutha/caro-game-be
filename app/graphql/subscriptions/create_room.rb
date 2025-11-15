module Subscriptions
  class CreateRoom < Subscriptions::BaseSubscription
    argument :room_id, ID, required: true

    field :room, Types::RoomType, null: false

    def subscribe(room_id:)
      {
        room: Room.new
      }
    end

    def update(room_id:)
      room = Room.find_by(id: room_id)

      { room: room }
    end
  end
end