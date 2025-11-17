module Mutations
  class CreateRoom < BaseMutation
    null true
    argument :name, String, required: true

    field :room, Types::RoomType, null: false

    def resolve(name:)
      require_authentication!

      room = Room.new(name: name, master: current_user)
      room.save!

      CaroGameBeSchema.subscriptions.trigger(
        :room_created,
        {},
        { room: room }
      )

      { room: room }
    end
  end
end