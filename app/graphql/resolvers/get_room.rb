# frozen_string_literal: true

module Resolvers
  class GetRoom < BaseResolver
    description "Get a specific room by ID"

    type Types::RoomType, null: false

    argument :room_id, ID, required: true

    def resolve(room_id:)
      require_authentication!
      Room.find(room_id)
    end
  end
end
