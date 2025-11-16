module Subscriptions
  class RoomCreated < Subscriptions::BaseSubscription
    field :room, Types::RoomType, null: false
    field :event_type, String, null: false

    def subscribe
      {}
    end

    def update
      {
        room: object[:room],
        event_type: object[:event_type] || 'room_created'
      }
    end
  end
end
