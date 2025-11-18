module Mutations
  class CreateRoom < BaseMutation
    description "Create a new room"

    argument :name, String, required: true

    field :room, Types::RoomType, null: false

    def resolve(name:)
      require_authentication!

      room = create_room(name)
      trigger_room_created(room)

      { room: room }
    end

    private

    def create_room(name)
      Room.create!(name: name, master: current_user)
    end

    def trigger_room_created(room)
      CaroGameBeSchema.subscriptions.trigger(:room_created, {}, { room: room })
    end
  end
end
