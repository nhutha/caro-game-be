module Subscriptions
  class RoomCreated < Subscriptions::BaseSubscription
    description "Subscribe to new room creation events"

    field :room, Types::RoomType, null: false

    def subscribe
      {}
    end

    def update
      { room: object[:room] }
    end
  end
end
