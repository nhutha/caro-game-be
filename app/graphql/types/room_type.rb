# frozen_string_literal: true

module Types
  class RoomType < Types::BaseObject
    description "A room where users can join to play games"

    # Core fields
    field :id, ID, null: false
    field :name, String, null: false
    field :status, String, null: false
    field :master_id, ID, null: false
    field :guest_id, ID, null: true

    # Relations
    field :master, Types::UserType, null: false
    field :guest, Types::UserType, null: true
    field :game, Types::GameType, null: true

    # Computed fields
    field :waiting_for_guest, Boolean, null: false, method: :waiting_for_guest?
    field :full, Boolean, null: false, method: :full?
    field :player_count, Integer, null: false

    # Timestamps
    field :created_at, GraphQL::Types::ISO8601DateTime, null: false
    field :updated_at, GraphQL::Types::ISO8601DateTime, null: false

    # Custom resolvers
    def player_count
      object.players.size
    end

    def status
      object.status.capitalize
    end
  end
end
