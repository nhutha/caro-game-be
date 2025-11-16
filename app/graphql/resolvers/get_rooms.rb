module Resolvers
  class GetRooms < BaseResolver
    type [Types::RoomType], null: false

    description "Get all rooms with pagination"

    def resolve
      Room.all
    end
  end
end