module Subscriptions
  class RoomUpdated < Subscriptions::BaseSubscription
    field :room, Types::RoomType, null: false

    def subscribe
      {}
    end

    def update
      {
        room: object[:room],
      }
    end
  end
end
