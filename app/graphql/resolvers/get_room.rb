module Resolvers
  class GetRoom < BaseResolver
    argument :room_id, ID, required: false

    type Types::RoomType, null: false

    description "Get all rooms with pagination"

    def resolve(room_id:)
      require_authentication!

      Room.find(room_id)
    end
  end
end