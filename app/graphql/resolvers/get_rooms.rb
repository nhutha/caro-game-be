# frozen_string_literal: true

module Resolvers
  class GetRooms < BaseResolver
    description "Get all available rooms"

    type [ Types::RoomType ], null: false

    def resolve
      Room.all.order(created_at: :desc)
    end
  end
end
