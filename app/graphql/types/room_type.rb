module Types
  class RoomType < Types::BaseObject
    description "A room where users can join to play games"

    field :id, ID, null: false
    field :name, String, null: false
    field :status, String, null: false
    field :master_id, ID, null: false
    field :guest_id, ID, null: true
    field :game, Types::GameType, null: true
    field :created_at, GraphQL::Types::ISO8601DateTime, null: false
    field :updated_at, GraphQL::Types::ISO8601DateTime, null: false

    # Custom fields
    field :master, Types::UserType, null: false
    field :guest, Types::UserType, null: true
    field :waiting_for_guest, Boolean, null: false
    field :full, Boolean, null: false
    field :player_count, Integer, null: false

    # Resolvers for associations
    def master
      object.master
    end

    def guest
      object.guest
    end

    # Resolvers for computed fields
    def waiting_for_guest
      object.waiting_for_guest?
    end

    def full
      object.full?
    end

    def player_count
      object.player_count
    end

    def status
      object.status.capitalize
    end
  end
end