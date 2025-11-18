# frozen_string_literal: true

module Types
  class QueryType < Types::BaseObject
    field :node, Types::NodeType, null: true, description: "Fetches an object given its ID." do
      argument :id, ID, required: true, description: "ID of the object."
    end

    def node(id:)
      context.schema.object_from_id(id, context)
    end

    field :nodes, [ Types::NodeType, null: true ], null: true, description: "Fetches a list of objects given a list of IDs." do
      argument :ids, [ ID ], required: true, description: "IDs of the objects."
    end

    def nodes(ids:)
      ids.map { |id| context.schema.object_from_id(id, context) }
    end

    field :profile, resolver: Resolvers::GetProfile, description: "Get current user profile"
    field :rooms, resolver: Resolvers::GetRooms, description: "Get list rooms"
    field :room, resolver: Resolvers::GetRoom, description: "Get a room by ID"
    field :leaderboard, resolver: Resolvers::GetLeaderboard, description: "Get user leaderboard"
    field :game_history, resolver: Resolvers::GetGameHistory, description: "Get game history"
    field :me, Types::UserType, null: true, description: "Get current logged in user"

    def me
      context[:current_user]
    end
  end
end
