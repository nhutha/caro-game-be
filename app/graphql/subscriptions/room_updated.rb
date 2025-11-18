module Subscriptions
  class RoomUpdated < Subscriptions::BaseSubscription
    description "Subscribe to room updates (player joined, game started, etc.)"

    argument :room_id, ID, required: true

    field :room, Types::RoomType, null: false
    field :event_type, String, null: false
    field :updated_by, Types::UserType, null: true

    def subscribe(room_id:)
      room = Room.find(room_id)

      {}
    end

    def update(room_id:)
      {
        room: object[:room],
        event_type: object[:event_type],
        updated_by: object[:updated_by]
      }
    end
  end
end
