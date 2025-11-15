module Subscriptions
  class RoomCreated < Subscriptions::BaseSubscription
    field :room, Types::RoomType, null: false

    def subscribe
      return {} unless context[:current_user]

      {}
    end

    def update()
      {
        room: object[:room],
      }
    end
  end
end
